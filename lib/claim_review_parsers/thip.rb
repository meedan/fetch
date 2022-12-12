# frozen_string_literal: true

# Parser for https://www.thip.media
class Thip < ClaimReviewParser
  include PaginatedReviewClaims
  def initialize(cursor_back_to_date = nil, overwrite_existing_claims=false, send_notifications = true)
    super(cursor_back_to_date, overwrite_existing_claims, send_notifications)
    @fact_list_page_parser = 'json'
  end

  def hostname
    "https://www.thip.media"
  end

  def fact_list_path(page = 1)
    "/wp-json/wp/v2/posts?categories=27,28,162,164,166,168,1886,1994,520&per_page=100&page=#{page}"
  end

  def url_extractor(response)
    response.collect{|x| x["link"]}
  end

  def get_claim_review_safely(raw_claim_review)
    claim_review = extract_ld_json_script_block(raw_claim_review["page"], 0)
    claim_review && claim_review["@graph"] && claim_review["@graph"][0] || {}
  end

  def parse_raw_claim_review(raw_claim_review)
    claim_review = get_claim_review_safely(raw_claim_review)
    {
      id: raw_claim_review['url'],
      created_at: (Time.parse(claim_review["datePublished"]) rescue nil),
      claim_review_headline: claim_review["name"].split(" &ndash;")[0..-2].join(" &ndash;"),
      claim_review_body: raw_claim_review["page"].search("div.wp-block-media-text").first.text.strip,
      claim_review_image_url: get_og_image_url(raw_claim_review),
      claim_review_reviewed: claim_review["claimReviewed"],
      claim_review_result: claim_review["reviewRating"] && claim_review["reviewRating"]["alternateName"],
      claim_review_result_score: claim_result_score_from_raw_claim_review(claim_review),
      claim_review_url: raw_claim_review['url'],
      raw_claim_review: claim_review
    }
  end
end
