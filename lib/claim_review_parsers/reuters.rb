# frozen_string_literal: true

class Reuters < ClaimReviewParser
  include PaginatedReviewClaims
  def initialize(cursor_back_to_date = nil, overwrite_existing_claims=false, send_notifications = true)
    super(cursor_back_to_date, overwrite_existing_claims, send_notifications)
    @user_agent = "Meedan/Fetch #{Settings.get("reuters_uuid")}" #randomly yanked UUID for Reuters
    @fact_list_page_parser = 'json'
    @escape_url_in_request = false
  end

  def self.deprecated
    true
  end

  def hostname
    'https://www.reuters.com'
  end

  def get_new_fact_page_urls(page)
    response = get_fact_page_urls(page)
    existing_urls = get_existing_urls(response.collect{|d| self.hostname+d["canonical_url"]})
    response.select{|d| !existing_urls.include?(self.hostname+d["canonical_url"] && Time.parse(d["published_time"]) > Time.parse("2023-11-27"))}
  end

  def parsed_fact_page(fact_page_response)
    parsed_page = parsed_page_from_url(self.hostname+fact_page_response["canonical_url"])
    [self.hostname+fact_page_response["canonical_url"], parse_raw_claim_review(QuietHashie[{ page: parsed_page, raw_response: fact_page_response, url: self.hostname+fact_page_response["canonical_url"] }])]
  end

  def url_extractor(response)
    response.dig("result", "articles") or []
  end

  def fact_list_path(page = 1)
    "/pf/api/v3/content/fetch/articles-by-section-alias-or-id-v1?query=%7B%22arc-site%22%3A%22reuters%22%2C%22offset%22%3A#{(page-1)*10}%2C%22requestId%22%3A3%2C%22section_id%22%3A%22%2Ffact-check%2F%22%2C%22size%22%3A20%2C%22uri%22%3A%22%2Ffact-check%2F%22%2C%22website%22%3A%22reuters%22%7D&d=176&_website=reuters"
  end

  def score_map
    {}
  end

  def claim_result_from_subhead(page)
    header = page.search('div[class^="article-body-module__content"]').first.search('h2[data-testid="Heading"]').last
    if header
      header.next_sibling.text.split(".").first
    end
  end

  def claim_result_from_page(page)
    claim_result_from_subhead(page)
  end

  def author_from_news_article(news_article)
    news_article["author"].class == Array ? news_article["author"][0]["name"] : news_article["author"]["name"]
  end

  def parse_raw_claim_review(raw_claim_review)
    claim_result = claim_result_from_page(raw_claim_review['page'])
    {
      id: raw_claim_review['raw_response']['id'],
      created_at: Time.parse(raw_claim_review['raw_response']['published_time']),
      author: raw_claim_review.dig('raw_response', 'authors', 0, 'name'),
      author_link: nil,
      claim_review_headline: raw_claim_review.dig('raw_response', 'title'),
      claim_review_body: raw_claim_review['page'].search('div[class^="article-body-module__content"]').children.text,
      claim_review_image_url: raw_claim_review.dig('raw_response', 'thumbnail', 'url'),
      claim_review_result: claim_result,
      claim_review_result_score: score_map[claim_result],
      claim_review_url: raw_claim_review['url'],
      raw_claim_review: raw_claim_review['raw_response']
    }
  end
end
