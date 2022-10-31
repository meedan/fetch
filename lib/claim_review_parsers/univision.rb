# frozen_string_literal: true

# Parser for https://syndicator.univision.com
class Univision < ClaimReviewParser
  include PaginatedReviewClaims
  def initialize(cursor_back_to_date = nil, overwrite_existing_claims=false, send_notifications = true)
    super(cursor_back_to_date, overwrite_existing_claims, send_notifications)
    @fact_list_page_parser = 'json'
  end

  def hostname
    'https://syndicator.univision.com'
  end

  def fact_list_path(page = 1, limit=20)
    "/web-api/widget?wid=$-719170345&offset=#{(page-1)*limit}&limit=#{limit}&url=https://www.univision.com/temas/detector-de-mentiras&mrpts=1667232059000"
  end

  def url_extractor(response)
    response["data"]["widget"]["contents"].collect{|x| x["uri"]}
  end

  def parse_raw_claim_review(raw_claim_review)
    binding.pry
    article = extract_ld_json_script_block(raw_claim_review["page"], -3)
    claim_review = extract_ld_json_script_block(raw_claim_review["page"], -4)
    return {} if article.nil?
    {
      id: raw_claim_review['url'],
      created_at: get_created_at_from_article(article),
      author: get_author_attribute(article, "name"),
      author_link: get_author_attribute(article, "url"),
      claim_review_headline: article["headline"],
      claim_review_body: claim_review_body_from_raw_claim_review(raw_claim_review),
      claim_review_image_url: article["image"] && article["image"]["url"],
      claim_review_result: claim_review["reviewRating"] && claim_review["reviewRating"]["alternateName"],
      claim_review_result_score: claim_result_score_from_raw_claim_review(claim_review),
      claim_review_url: raw_claim_review['url'],
      raw_claim_review: {article: article}
    }
  end
end