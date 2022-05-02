# frozen_string_literal: true

# Eventually all subclasses here will need standardization about
class ClaimReviewParser
  attr_accessor :fact_list_page_parser, :run_in_parallel, :overwrite_existing_claims
  def self.enabled_subclasses
    self.subclasses.reject(&:deprecated)
  end

  def self.deprecated
    false
  end

  def self.persistable_raw_claim_review_services
    ClaimReviewParser.parsers.select{|k,v| v.persistable?}.keys.uniq
  end

  def self.persistable?
    @persistable != false
  end

  def service_key
    nil
  end

  def initialize(cursor_back_to_date = nil, overwrite_existing_claims = false, send_notifications = true, client=Settings.s3_client)
    @fact_list_page_parser ||= 'html'
    @simple_page_urls ||= true
    @run_in_parallel = true
    @logger = Logger.new(STDOUT)
    @current_claims = []
    @cookies = get_cookies(client)
    @overwrite_existing_claims = overwrite_existing_claims
    @cursor_back_to_date = cursor_back_to_date
    @send_notifications = send_notifications
  end

  def get_cookies(client)
    if URI.parse(Settings.get('cookie_file')).scheme == "s3"
      bucket, key = Settings.get('cookie_file').gsub("s3://", "").split("/")
      all_cookies = JSON.parse(client.get_object(bucket: bucket, key: key).body.read)
    else
      all_cookies = JSON.parse(File.read(Settings.get('cookie_file')))
    end
    all_cookies[self.class.service.to_s]||{}
  end

  def self.service
    to_s.underscore.to_sym
  end

  def self.parsers
    QuietHashie[
      Hash[ClaimReviewParser.enabled_subclasses.map do |sc|
        [sc.service, sc]
      end]
    ]
  end

  def self.run(service, cursor_back_to_date = nil, overwrite_existing_claims = false, send_notifications = true)
    parsers[service] && parsers[service].new(cursor_back_to_date, overwrite_existing_claims, send_notifications).get_claim_reviews
  end

  def self.record_service_heartbeat(service)
    $REDIS_CLIENT.setex(ClaimReview.service_heartbeat_key(service), Settings.get('service_heartbeat_ttl'), service)
  end

  def store_to_db(claim_reviews, service)
    claim_reviews.each do |parsed_claim_review|
      ClaimReview.store_claim_review(QuietHashie[parsed_claim_review], service, @overwrite_existing_claims, @send_notifications)
    end
  end

  def make_request
    retry_count = 0
    begin
      yield
    rescue RestClient::BadGateway, RestClient::NotFound, SocketError, Errno::ETIMEDOUT => e
      if retry_count < 3
        retry_count += 1
        sleep(1)
        retry
      else
        Error.log(e)
        return nil
      end
    end
  end

  def request(method, url, payload=nil)
    make_request do
      headers = @user_agent ? {user_agent: @user_agent} : {}
      proxy = @proxy ? @proxy : nil
      RestClient::Request.execute(
        method: method,
        url: url,
        payload: payload,
        cookies: @cookies,
        headers: headers,
        proxy: proxy
      )
    end
  end

  def post_url(url, body)
    request(:post, url, body)
  end

  def get_url(url)
    request(:get, url)
  end

  def get_existing_urls(urls)
    if @cursor_back_to_date
      # force checking every URL directly instead of bypassing quietly...
      []
    else
      ClaimReview.existing_urls(urls, self.class.service)
    end
  end

  def process_claim_reviews(claim_reviews)
    store_to_db(
      claim_reviews, self.class.service
    )
    claim_reviews
  end

  def finished_iterating?(claim_reviews)
    times = claim_reviews.map { |x| QuietHashie[x][:created_at] }.compact
    oldest_time = if times.empty?
                    @cursor_back_to_date
                  else
                    times.min
                  end
    claim_reviews.empty? || oldest_time.nil? || (!@cursor_back_to_date.nil? && oldest_time < @cursor_back_to_date)
  end

  def parse_raw_claim_reviews(raw_claim_reviews)
    Parallel.map(raw_claim_reviews, in_processes: Settings.parallelism_for_task(:parse_raw_claim_reviews), progress: "Downloading #{self.class} Corpus") do |raw_claim_review|
      parse_raw_claim_review(raw_claim_review)
    end.compact
  end
  
  def extract_all_ld_json_script_blocks(page, search_path="script")
    page.search(search_path).select{|x| x.attributes["type"] && x.attributes["type"].value == "application/ld+json"}
  end

  def extract_ld_json_script_block(page, index, search_path="script")
    script_block = page && extract_all_ld_json_script_blocks(page, search_path)[index]
    script_block
    if !script_block.nil?
      begin
        parsed = JSON.parse(script_block.text)
        return parsed
      rescue JSON::ParserError
        return nil
      end
    end
  end

  def og_timestamps_from_raw_claim_review(raw_claim_review)
    raw_claim_review["page"].search("meta").select{|x|
      x.attributes["property"] && x.attributes["property"].value.include?("_time")
    }.collect{|x|
      Time.parse(x.attributes["content"].value) rescue nil
    }.compact
  end

  def value_from_og_tag(og_tag)
    og_tag.attributes["content"].value if og_tag
  end

  def search_for_og_tags(page, og_tags)
    page.search("meta").select{|x| x.attributes["property"] && og_tags.include?(x.attributes["property"].value)}.compact.first
  end

  def og_date_from_raw_claim_review(raw_claim_review)
    value_from_og_tag(
      search_for_og_tags(raw_claim_review["page"], ["article:published_time", "article:modified_time", "article:updated_time"])
    )
  end

  def self.test_parser_on_url(url)
    response = self.new.request(:get, url)
    params = {"page" => Nokogiri.parse(response), "url" => url}
    self.new.parse_raw_claim_review(params)
  end

  def service_key_is_needed?
    if service_key && Settings.blank?(service_key)
      puts "#{service_key} is missing. Can't update #{self.class.service}"
      return true
    end
    false
  end
end
