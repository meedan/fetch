# frozen_string_literal: true

# Parser for https://noticias.uol.com.br
class UOLComprova < ClaimReviewParser
  include PaginatedReviewClaims
  attr_accessor :next_page
  def self.interevent_time
    60*5
  end

  def initialize(cursor_back_to_date = nil, overwrite_existing_claims=false, send_notifications = true)
    super(cursor_back_to_date, overwrite_existing_claims, send_notifications)
    @next_page = nil
  end

  def hostname
    'https://noticias.uol.com.br'
  end

  def fact_list_path(next_page=nil)
    "/comprova/?next=#{next_page}"
  end

  def url_extraction_search
    "div.row div.thumbnails-item a"
  end

  def url_extractor(atag)
    atag.attributes['href'].value
  end

  def parsed_fact_list_page(next_page=nil)
    response = super(next_page)
    search_button = response.search("button.btn-search").first
    @next_page = search_button && search_button.attributes["data-next"].value
    response
  end

  def get_claim_reviews
    processed_claim_reviews = store_claim_reviews_for_page(@next_page)
    (processed_claim_reviews = store_claim_reviews_for_page(@next_page)) until finished_iterating?(processed_claim_reviews)
  end

  def claim_review_body_from_raw_claim_review(raw_claim_review)
    raw_claim_review["page"].search("div.text p").first.text rescue nil
  end
  
  def get_created_at_from_claim_review_or_raw_claim_review(claim_review, raw_claim_review)
    ia_date_value = raw_claim_review["page"].search("p.p-author.time")[0].attributes["ia-date-publish"].value rescue nil
    claim_review["datePublished"] && Time.parse(claim_review["datePublished"]) || Time.parse(ia_date_value)
  end

  def get_headline_from_raw_claim_review(raw_claim_review)
    raw_claim_review["page"].search("h1 span i.custom-title").text
  end

  def parse_raw_claim_review(raw_claim_review)
    claim_review = extract_ld_json_script_block(raw_claim_review["page"], 0).select{|x| x.to_s.include?("ClaimReview")}
    claim_review = claim_review && claim_review[0] || {}
    {
      id: raw_claim_review['url'],
      created_at: get_created_at_from_claim_review_or_raw_claim_review(claim_review, raw_claim_review),
      author: claim_review["author"] && claim_review["author"]["name"] || "Projeto Comprova",
      author_link: claim_review["author"] && claim_review["author"]["url"],
      claim_review_headline: claim_review["headline"] || get_headline_from_raw_claim_review(raw_claim_review),
      claim_review_body: claim_review_body_from_raw_claim_review(raw_claim_review),
      claim_review_reviewed: claim_review["claimReviewed"],
      claim_review_image_url: claim_review_image_url_from_raw_claim_review(raw_claim_review),
      claim_review_result: claim_review["reviewRating"] && claim_review["reviewRating"]["alternateName"],
      claim_review_result_score: claim_result_score_from_raw_claim_review(claim_review),
      claim_review_url: raw_claim_review['url'],
      raw_claim_review: claim_review
    }
  end
end