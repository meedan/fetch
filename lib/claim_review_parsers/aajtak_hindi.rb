# frozen_string_literal: true

# Parser for https://www.aajtak.in
class AajtakHindi < ClaimReviewParser
  include PaginatedReviewClaims
  def initialize(cursor_back_to_date = nil, overwrite_existing_claims=false, send_notifications = true)
    super(cursor_back_to_date, overwrite_existing_claims, send_notifications)
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

  def get_author_attribute(article, attribute)
    article && article["author"] && article["author"][0] && article["author"][0][attribute]
  end

  def claim_review_body_from_raw_claim_review(raw_claim_review)
    raw_claim_review["page"].search("div.box-gry").select{|x| x.text.include?("निष्कर्ष")}.first.search("p").text rescue nil
  end

  def parse_raw_claim_review(raw_claim_review)
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
