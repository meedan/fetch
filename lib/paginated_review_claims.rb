# frozen_string_literal: true

# Base-level ClaimReviewParser code where claim providers have a paginated
# index page of claims and then require visting each URL-specified claim directly
require_relative('review_rating_parser')
module PaginatedReviewClaims
  include ReviewRatingParser

  def og_images_from_raw_claim_review(raw_claim_review)
    raw_claim_review["page"].search("meta").select{|x| x.attributes["property"] && x.attributes["property"].value == "og:image"}
  end

  def og_image_url_from_og_image(og_image)
    og_image.attributes["content"].value
  end

  def og_image_url_from_raw_claim_review(raw_claim_review)
    image = og_images_from_raw_claim_review(raw_claim_review).first
    og_image_url_from_og_image(image) if image
  end

  def claim_review_image_url_from_raw_claim_review(raw_claim_review)
    og_image_url_from_raw_claim_review(raw_claim_review)
  rescue StandardError => e
    Error.log(e, {raw_claim_review: raw_claim_review})
  end

  def get_created_at_from_article(article)
    (Time.parse(article['datePublished'] || article["dateModified"]) rescue nil)
  end

  def nokogiri_parse(response)
    Nokogiri.parse(response)
  end

  def json_parse(response)
    JSON.parse(response)
  end

  def parsed_fact_list_page(page = 1)
    response = get_url(hostname + fact_list_path(page))
    return if response.nil?
    if @fact_list_page_parser == 'html'
      nokogiri_parse(response)
    elsif @fact_list_page_parser == 'json'
      json_parse(response)
    elsif @fact_list_page_parser == "html_body_encased_html"
      nokogiri_parse("<html><body>"+response+"</body></html>")
    elsif @fact_list_page_parser == 'html_first_then_json'
      if page == 1
        nokogiri_parse(response)
      else
        json_parse(response)
      end
    end
  end

  def extract_urls_from_html(response)
    response.search(url_extraction_search).map { |atag| url_extractor(atag) }.compact.uniq
  end

  def get_fact_page_urls(page = 1)
    response = parsed_fact_list_page(page)
    if response
      if ["html", "html_body_encased_html"].include?(@fact_list_page_parser)
        extract_urls_from_html(response)
      elsif @fact_list_page_parser == 'json'
        url_extractor(response)
      elsif @fact_list_page_parser == 'html_first_then_json'
        url_extractor(response)
      end
    else
      []
    end
  end

  def parsed_page_from_url(fact_page_url)
    response = get_url(fact_page_url)
    Nokogiri.parse(response) if response
  rescue StandardError => e
    Error.log(e, {fact_page_url: fact_page_url})
  end

  def parsed_fact_page(fact_page_url)
    parsed_page = parsed_page_from_url(fact_page_url)
    return if parsed_page.nil?
    [fact_page_url, parse_raw_claim_review(QuietHashie[{ page: parsed_page, url: fact_page_url }])]
  end

  def get_new_fact_page_urls(page)
    page_urls = get_fact_page_urls(page)
    existing_urls = get_existing_urls(page_urls)
    page_urls - existing_urls
  end

  def store_claim_reviews_for_page(page)
    process_claim_reviews(
      get_parsed_fact_pages_from_urls(
        get_new_fact_page_urls(
          page
        )
      )
    )
  end

  def get_claim_reviews
    page = 1
    processed_claim_reviews = store_claim_reviews_for_page(page)
    until finished_iterating?(processed_claim_reviews)
      page += 1
      processed_claim_reviews = store_claim_reviews_for_page(page)
    end
  end

  def safe_parsed_fact_page(fact_page_url)
    parsed_fact_page(fact_page_url)
  rescue StandardError => e
    Error.log(e, {fact_page_url: fact_page_url})
  end

  def get_parsed_fact_pages_from_urls(urls)
    if @run_in_parallel
      Hash[Parallel.map(urls, in_processes: Settings.parallelism_for_task(:get_parsed_fact_pages_from_urls), progress: "Downloading #{self.class} Corpus") do |fact_page_url|
        safe_parsed_fact_page(fact_page_url)
      end.compact].values
    else
      sleep(@per_article_sleep_time) if @per_article_sleep_time
      Hash[urls.map do |fact_page_url|
        safe_parsed_fact_page(fact_page_url)
      end.compact].values
    end
  end
end
