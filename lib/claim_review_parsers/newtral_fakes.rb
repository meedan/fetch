# frozen_string_literal: true

# Parser for https://www.newtral.es
class NewtralFakes < ClaimReviewParser
  include PaginatedReviewClaims
  def initialize(cursor_back_to_date = nil, overwrite_existing_claims=false, send_notifications = true)
    super(cursor_back_to_date, overwrite_existing_claims, send_notifications)
    @fact_list_page_parser = 'json'
  end

  def hostname
    'https://www.newtral.es'
  end

  def fact_list_path(page = 1)
    "/wp-json/nwtfmg/v1/fakes?page=#{page}&posts_per_page=15&firstDate=2018-01-01&lastDate=#{Time.now.strftime("%Y-%m-%d")}"
  end

  def url_extractor(response)
    response["data"].collect{|r| r["url"]}
  end

  def claim_review_body_from_raw_claim_review(raw_claim_review)
    raw_claim_review["page"].search("div.box-gry").select{|x| x.text.include?("निष्कर्ष")}.first.search("p").text rescue nil
  end

  def parse_raw_claim_review(raw_claim_review)
    binding.pry
    ld_json_object = extract_ld_json_script_block(raw_claim_review["page"], 0)
    claim_review = ld_json_object["@graph"].select{|x| x["@type"]=="ClaimReview"}.first
    {
      id: raw_claim_review['url'],
      created_at: Time.parse(claim_review["datePublished"]),
      author: claim_review["author"]["name"],
      author_link: claim_review["author"]["url"],
      claim_review_headline: value_from_og_tags(raw_claim_review, ["og:description"]),
      claim_review_body: claim_review_body_from_raw_claim_review(raw_claim_review),
      claim_review_image_url: get_og_image_url(raw_claim_review),
      claim_review_result: claim_review["reviewRating"] && claim_review["reviewRating"]["alternateName"],
      claim_review_result_score: claim_result_score_from_raw_claim_review(claim_review),
      claim_review_url: raw_claim_review['url'],
      raw_claim_review: {ld_json_object: ld_json_object}
    }
  end
end
