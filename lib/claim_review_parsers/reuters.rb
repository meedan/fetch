# frozen_string_literal: true

class Reuters < ClaimReviewParser
  include PaginatedReviewClaims
  def initialize(cursor_back_to_date = nil, overwrite_existing_claims=false, send_notifications = true)
    super(cursor_back_to_date, overwrite_existing_claims, send_notifications)
    @user_agent = "Meedan/Fetch #{Settings.get("reuters_uuid")}" #randomly yanked UUID for Reuters
  end

  def self.deprecated
    true
  end

  def hostname
    'https://www.reuters.com'
  end

  def fact_list_path(page = 1)
    "/news/archive/reuterscomservice?view=page&page=#{page}&pageSize=10"
  end

  def url_extraction_search
    'div.column1 section.module-content article.story div.story-content a'
  end

  def url_extractor(atag)
    hostname + atag.attributes['href'].value
  end

  def claim_result_from_subhead(page)
    header = page.search('div[class^="article-body__content"]').first.search('h2[data-testid="Heading"]').last
    if header
      header.next_sibling.text.split(".").first
    end
  end

  def score_map
    {}
  end

  def claim_result_from_page(page)
    claim_result_from_subhead(page)
  end

  def author_from_news_article(news_article)
    news_article["author"].class == Array ? news_article["author"][0]["name"] : news_article["author"]["name"]
  end

  def parse_raw_claim_review(raw_claim_review)
    claim_result = claim_result_from_page(raw_claim_review['page'])
    news_article = extract_ld_json_script_block(raw_claim_review["page"], 0)
    {
      id: raw_claim_review['url'],
      created_at: Time.parse(news_article["dateCreated"]),
      author: author_from_news_article(news_article),
      author_link: nil,
      claim_review_headline: news_article["headline"],
      claim_review_body: raw_claim_review['page'].search('div[class^="article-body__content"]').children.select { |x| x.name == "p" }.first.text,
      claim_review_image_url: news_article["image"]["url"],
      claim_review_result: claim_result,
      claim_review_result_score: score_map[claim_result],
      claim_review_url: raw_claim_review['url'],
      raw_claim_review: news_article
    }
  end
end
