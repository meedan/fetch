# frozen_string_literal: true

# Parser for https://www.desifacts.org/
class Tayo < ClaimReviewParser
  include PaginatedReviewClaims
  def self.includes_service_keyword
    true
  end

  def hostname
    "https://www.tayohelp.com"
  end

  def get_article_urls
    Nokogiri.parse(get_url(hostname+"/hc/sitemap.xml")).search("url loc").collect(&:text).select{|u| u.include?("/articles/")}
  end
  
  def get_new_article_urls
    page_urls = get_article_urls
    page_urls-get_existing_urls(page_urls)
  end

  def get_claim_reviews
    get_parsed_fact_pages_from_urls(get_new_article_urls)
  end

  def title_from_raw_claim_review(raw_claim_review)
    raw_claim_review["page"].search('meta[property="og:title"]').first.attributes["content"].value
  end

  def article_node_from_raw_claim_review(raw_claim_review)
    raw_claim_review["page"].search("section.article-info div.article-content div.article-body").first
  end
  
  def timestamp_from_raw_claim_reivew(raw_claim_review)
    Time.parse(article_node_from_raw_claim_review(raw_claim_review).search("time.posted-on")[0].attributes["datetime"].value)
  end

  def author_from_raw_claim_review(raw_claim_review)
    article_node_from_raw_claim_review(raw_claim_review).search("span.byline").text
  end


  def parse_raw_claim_review(raw_claim_review)
    {
      id: raw_claim_review['url'],
      created_at: timestamp_from_raw_claim_reivew(raw_claim_review),
      author: author_from_raw_claim_review(raw_claim_review),
      claim_review_headline: title_from_raw_claim_review(raw_claim_review),
      claim_review_body: article_node_from_raw_claim_review(raw_claim_review).search("p").collect(&:text).join(" "),
      claim_review_image_url: og_image_url_from_og_image(og_images_from_raw_claim_review(raw_claim_review).last),
      claim_review_url: raw_claim_review['url'],
    }
  end
end