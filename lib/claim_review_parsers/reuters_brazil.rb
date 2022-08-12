# frozen_string_literal: true

class ReutersBrazil < Reuters
  include PaginatedReviewClaims
  def self.deprecated
    false
  end

  def fact_list_path(page = 1)
    "/news/archive/factcheckportuguesenew?view=page&page=#{page}&pageSize=10"
  end

  def claim_result_from_subhead(page)
    header = page.search('div.ArticleBodyWrapper h3').first || page.search('div.ArticleBodyWrapper h2').first
    if header
      header.next_sibling.text
    end
  end

  def claim_result_from_page(page)
    claim_result_from_subhead(page)
  end

  def parse_raw_claim_review(raw_claim_review)
    claim_result = claim_result_from_page(raw_claim_review['page'])
    news_article = extract_ld_json_script_block(raw_claim_review["page"], 0)
    {
      id: raw_claim_review['url'],
      created_at: Time.parse(news_article["dateCreated"]),
      author: news_article["author"]["name"],
      author_link: nil,
      claim_review_headline: news_article["headline"],
      claim_review_body: raw_claim_review['page'].search('div.ArticleBodyWrapper').children.select{|x| x.name == "p"}.first.text,
      claim_review_image_url: news_article["image"]["url"],
      claim_review_result: claim_result,
      claim_review_result_score: claim_result.to_s.downcase.include?('true') ? 0 : 1,
      claim_review_url: raw_claim_review['url'],
      raw_claim_review: news_article
    }
  end
end
