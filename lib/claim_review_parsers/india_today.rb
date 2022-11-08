# frozen_string_literal: true

class IndiaToday < ClaimReviewParser
  include PaginatedReviewClaims
  def initialize(cursor_back_to_date = nil, overwrite_existing_claims=false, send_notifications = true)
    super(cursor_back_to_date, overwrite_existing_claims, send_notifications)
    @fact_list_page_parser = 'json'
  end

  def hostname
    'https://www.indiatoday.in'
  end

  def fact_list_path(page = 1)
    "/api/ajax/newslist?page=#{page-1}&id=1792990&type=story&display=12"
  end

  def url_extractor(page_data)
    page_data["data"]["content"].collect{|x| self.hostname+x["canonical_url"]}
  end

  def get_ld_json_by_type_from_raw_claim_review(raw_claim_review, ld_json_type)
    extract_all_ld_json_script_blocks(raw_claim_review["page"]).collect{|x|
      parse_script_block(x)
    }.select{|x|
      x.class == Hash && x["@type"] == ld_json_type
    }.first
  end

  def parse_raw_claim_review(raw_claim_review)
    claim_review = get_ld_json_by_type_from_raw_claim_review(raw_claim_review, "ClaimReview")
    news_article = get_ld_json_by_type_from_raw_claim_review(raw_claim_review, "NewsArticle")
    {
      id: raw_claim_review['url'],
      created_at: (Time.parse(news_article && news_article["datePublished"]) rescue nil),
      author: news_article && news_article["author"] && news_article["author"]["name"],
      author_link: news_article && news_article["author"] && news_article["author"]["url"],
      claim_review_headline: news_article && news_article["headline"],
      claim_review_body: news_article && news_article["description"],
      claim_review_image_url: get_og_image_url(raw_claim_review),
      claim_review_reviewed: claim_review && claim_review["claimReviewed"],
      claim_review_result: claim_review && claim_review["reviewRating"] && claim_review["reviewRating"]["alternateName"],
      claim_review_result_score: claim_result_score_from_raw_claim_review(claim_review),
      claim_review_url: raw_claim_review['url'],
      raw_claim_review: {claim_review: claim_review, news_article: news_article}
    }
  end
end