# frozen_string_literal: true

# Parser for https://africacheck.org
class AfricaCheck < ClaimReviewParser
  include PaginatedReviewClaims
  def self.deprecated
    true
  end

  def hostname
    'https://africacheck.org'
  end

  def request_fact_page(page)
    post_url(
      self.hostname+"/views/ajax?_wrapper_format=drupal_ajax",
      "view_name=article&view_display_id=pg_landing&view_args=&view_path=%2Ffact-checks&view_base_path=fact-checkspager_element=0&field_article_type_value=All&field_rated_value=All&field_country_value=All&sort_bef_combine=created_DESC&sort_by=created&sort_order=DESC&page=2"
    )
  end

  def url_from_raw_article(a_tag)
    a_tag.attributes["href"].value
  end

  def get_page_urls(page)
    Nokogiri.parse(
      JSON.parse(
        request_fact_page(page)
      )[-1]["data"]
    ).search("h3 a").collect{|a| self.hostname+url_from_raw_article(a)}
  end

  def get_new_fact_page_urls(page)
    urls = get_page_urls(page)
    urls-get_existing_urls(urls)
  end

  def claim_review_image_url_from_raw_claim_review(raw_claim_review)
    raw_claim_review["page"].search("img.attachment-articleMain").first.attributes["src"].value
  rescue StandardError => e
    Error.log(e, {raw_claim_review: raw_claim_review})
  end

  def claim_review_reviewed_from_raw_claim_review(raw_claim_review)
    raw_claim_review["page"].search("div.article-details__claims div").text
  end

  def rating_map
    {
      'correct' => 1.0,
      'mostly-correct' => 0.75,
      'unproven' => 0.5,
      'misleading' => 0.5,
      'exaggerated' => 0.5,
      'downplayed' => 0.5,
      'incorrect' => 0,
      'checked' => 0.5
    }
  end

  def rating_from_raw_claim_review(raw_claim_review)
    if raw_claim_review && raw_claim_review["page"]
      rating_text = raw_claim_review["page"].search('div.article-details__verdict div').first&.attributes&.dig("class")&.value.to_s.split(" ").select{|x| x.include?("rating--")}.first.to_s.split("--").last
      [rating_text, rating_map[rating_text]]
    else
      [nil, nil]
    end
  end

  def extract_news_article_from_ld_json_script_block(ld_json_script_block)
    ld_json_script_block &&
    ld_json_script_block["@graph"] &&
    ld_json_script_block["@graph"].select{|x| x["@type"] == "NewsArticle"}[0]
  end

  def parse_raw_claim_review(raw_claim_review)
    claim_review = extract_news_article_from_ld_json_script_block(extract_ld_json_script_block(raw_claim_review["page"], 0))
    claim_review_result, claim_review_result_score = rating_from_raw_claim_review(raw_claim_review)
    if claim_review
      {
        id: raw_claim_review['url'],
        created_at: get_created_at_from_article(claim_review),
        author: claim_review["author"]["name"],
        author_link: claim_review["author"]["url"],
        claim_review_headline: claim_review["headline"],
        claim_review_body: claim_review["description"],
        claim_review_reviewed: claim_review_reviewed_from_raw_claim_review(raw_claim_review),
        claim_review_image_url: claim_review["image"]["url"],
        claim_review_result: claim_review_result,
        claim_review_result_score: claim_review_result_score,
        claim_review_url: raw_claim_review['url'],
        raw_claim_review: claim_review
      }
    else
      {
        id: raw_claim_review['url'],
      }
    end
  end
end
