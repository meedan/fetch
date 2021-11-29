# frozen_string_literal: true

# Parser for https://factly.in
class AajtakHindi < ClaimReviewParser
  include PaginatedReviewClaims
  def initialize(cursor_back_to_date = nil, overwrite_existing_claims=false)
    super(cursor_back_to_date, overwrite_existing_claims)
    @fact_list_page_parser = 'json'
  end

  def hostname
    'https://www.aajtak.in'
  end

  def fact_list_path(page = 1)
    "/ajax/load-more-special-listing?id=#{page-1}&type=story/photo_gallery/video/breaking_news&path=/fact-check"
  end

  def url_extractor(response)
    Nokogiri.parse("<html><body>"+response['html_content']+"</html></body>").search("li a").collect{|x| x.attributes['href'].value}
  end

  def parse_raw_claim_review(raw_claim_review)
    article = extract_ld_json_script_block(raw_claim_review["page"], -3)
    claim_review = extract_ld_json_script_block(raw_claim_review["page"], -4)
    {
      id: raw_claim_review['url'],
      created_at: Time.parse(article['datePublished']),
      author: article["author"][0]["name"],
      author_link: article["author"][0]["url"],
      claim_review_headline: article["headline"],
      claim_review_body: article["articleBody"],
      claim_review_image_url: article["image"]["url"],
      claim_review_result: claim_review["reviewRating"] && claim_review["reviewRating"]["alternateName"],
      claim_review_result_score: claim_result_score_from_raw_claim_review(claim_review),
      claim_review_url: raw_claim_review['url'],
      raw_claim_review: {article: article}
    }
  end
end
