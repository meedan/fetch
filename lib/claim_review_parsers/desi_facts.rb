# frozen_string_literal: true

# Parser for https://www.desifacts.org/
class DesiFacts < ClaimReviewParser
  include PaginatedReviewClaims
  def self.includes_service_keyword
    true
  end

  def initialize(cursor_back_to_date = nil, overwrite_existing_claims=false, send_notifications = true)
    super(cursor_back_to_date, overwrite_existing_claims, send_notifications)
    @per_article_sleep_time = 3
    @run_in_parallel = false
  end
  
  def hostnames
    [
      "https://www.desifacts.org",
      "https://hi.desifacts.org",
      "https://bn.desifacts.org",
    ]
  end

  def is_claim_or_explainer(image_title_node)
    ["दावा", "स्पष्टीकरण", "দাবি", "ব্যাখ্যাকারী", "claim", "explainer"].collect{|clause| image_title_node.text.downcase.include?(clause)}.include?(true)
  end

  def is_article_url(url)
    image_node = url.children.select{|x| x.name == "image"}.first
    image_title_node = image_node && image_node.children.select{|x| x.name == "title"}.first
    image_node && image_title_node && is_claim_or_explainer(image_title_node)
  end

  def get_article_urls
    hostnames.collect do |hostname|
      Nokogiri.parse(get_url(hostname+"/sitemap.xml")).search("url").select{|url| is_article_url(url)}.collect{|x| x.search("loc").text}
    end.flatten
  end
  
  def get_new_article_urls
    page_urls = get_article_urls
    page_urls-get_existing_urls(page_urls)
  end

  def get_claim_reviews
    process_claim_reviews(get_parsed_fact_pages_from_urls(get_new_article_urls))
  end

  def find_claim_review(page)
    extract_all_ld_json_script_blocks(page).collect{|b| JSON.parse(b.text)}.select{|x| x["@type"] == "Article"}.first
  end

  def parse_raw_claim_review(raw_claim_review)
    article = find_claim_review(raw_claim_review["page"]) || {}
    timestamp = [article["datePublished"], article["dateModified"]].compact.sort.first
    claim_review_result = raw_claim_review["page"].search("figcaption div.image-caption p").text
    headline = raw_claim_review["page"].search("h1.entry-title").text
    {
      id: raw_claim_review['url'],
      created_at: timestamp && Time.parse(timestamp),
      author: article["author"],
      claim_review_headline: headline.empty? ? article["headline"] : headline,
      claim_review_body: raw_claim_review["page"].search("p.sqsrte-large em").text,
      claim_review_image_url: article["image"],
      claim_review_result: claim_review_result,
      claim_review_result_score: claim_review_result == "True" ? 1 : 0,
      claim_review_url: raw_claim_review['url'],
      raw_claim_review: article
    }
  end
end
