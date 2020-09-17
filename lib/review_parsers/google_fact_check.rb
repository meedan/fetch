# frozen_string_literal: true

class GoogleFactCheck < ReviewParser
  def host
    'https://factchecktools.googleapis.com'
  end

  def path
    '/v1alpha1/claims:search'
  end

  def make_get_request(path, params)
    url = host + path + '?' + URI.encode_www_form(params.merge(key: SETTINGS['google_api_key']))
    JSON.parse(
      RestClient.get(
        url
      ).body
    )
  end

  def get(path, params)
    retry_count = 0
    begin
      make_get_request(path, params)
    rescue RestClient::ServiceUnavailable
      retry_count += 1
      sleep(1)
      retry if retry_count < 3
      return {} if retry_count >= 3
    end
  end

  def get_query(query, offset = 0)
    get(path, { query: query, pageSize: 100, offset: offset })
  end

  def get_publisher(publisher, offset = 0)
    get(path, { reviewPublisherSiteFilter: publisher, pageSize: 100, offset: offset })
  end

  def get_all_for_query(query)
    results_page = get_query(query)['claims']
    results = results_page || []
    offset = 0
    while results_page && !results_page.empty?
      offset += 100
      results_page = get_query(query, offset)['claims'] || []
      results_page.each do |r|
        results << r
      end
    end
    results
  end

  def get_new_from_publisher(publisher, offset)
    claims = get_publisher(publisher, offset)['claims'] || []
    existing_urls = get_existing_urls(
      claims.map do |claim|
        claim_url_from_raw_claim(claim)
      end.compact
    )
    claims.select { |claim| claim['claimReview']&.first && !existing_urls.include?(claim['claimReview'].first['url']) }
  end

  def store_claims_for_publisher_and_offset(publisher, offset)
    process_claims(
      parse_raw_claims(
        get_new_from_publisher(
          publisher, offset
        )
      )
    )
  end

  def get_all_for_publisher(publisher)
    offset = 0
    results_page = store_claims_for_publisher_and_offset(publisher, offset)
    until results_page.empty?
      offset += 100
      results_page = store_claims_for_publisher_and_offset(publisher, offset)
    end
  end

  def snowball_publishers_from_queries(queries)
    queries.map do |query|
      snowball_publishers_from_query(query)
    end.flatten.uniq
  end

  def snowball_publishers_from_query(query = 'election')
    claims = Hash[get_all_for_query(query).map { |r| [r['claimReview'].first['url'], r] }]
    claims.values.map { |r| r['claimReview'].map { |cr| cr['publisher']['site'] } }.flatten.uniq
  end

  def snowball_claims_from_publishers(publishers)
    Parallel.map(publishers, in_processes: 1, progress: 'Downloading data from all publishers') do |publisher|
      get_all_for_publisher(publisher)
    end
  end

  def default_queries
    ['选举', 'elección', 'election', 'انتخاب', 'चुनाव', 'নির্বাচন', 'eleição', 'выборы', '選挙', 'ਚੋਣ', 'निवडणूक', 'ఎన్నికల', 'seçim', '선거', 'élection', 'Wahl', 'cuộc bầu cử', 'தேர்தல்', 'انتخابات']
  end

  def get_claims(seed_queries = default_queries)
    snowball_claims_from_publishers(
      snowball_publishers_from_queries(
        seed_queries
      )
    )
  end

  def claim_url_from_raw_claim(raw_claim)
    raw_claim['claimReview'][0]['url']
  rescue StandardError
    nil
  end

  def created_at_from_raw_claim(raw_claim)
    Time.parse(raw_claim['claimReview'][0]['reviewDate'] || raw_claim['claimDate'])
  rescue StandardError
    nil
  end

  def parse_raw_claim(raw_claim)
    {
      id: Digest::MD5.hexdigest(raw_claim['claimReview'][0]['url']),
      created_at: created_at_from_raw_claim(raw_claim),
      author: raw_claim['claimReview'][0]['publisher']['name'],
      author_link: raw_claim['claimReview'][0]['publisher']['site'],
      claim_headline: raw_claim['claimReview'][0]['title'],
      claim_body: raw_claim['text'],
      claim_result: raw_claim['claimReview'][0]['textualRating'],
      claim_result_score: nil,
      claim_url: claim_url_from_raw_claim(raw_claim),
      raw_claim: raw_claim
    }
  end
end
