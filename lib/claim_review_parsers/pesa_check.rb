# frozen_string_literal: true

# Parser for https://medium.com/feed/@pesacheck
class PesaCheck < ClaimReviewParser
  include PaginatedReviewClaims

  def get_articles
    JSON.parse(get_url("https://api.rss2json.com/v1/api.json?rss_url=https://medium.com/feed/@pesacheck"))["items"]
  end
  
  def get_claim_reviews
    articles = get_articles
    existing_urls = get_existing_urls(articles.collect{|x| x["link"]})
    process_claim_reviews(articles.reject{|x| existing_urls.include?(x["link"])}.collect{|x| parse_raw_claim_review(x)})
  end

  def parse_raw_claim_review(feed_item)
    {
      id: feed_item["link"],
      created_at: Time.parse(feed_item["pubDate"]),
      author: feed_item["author"],
      claim_review_headline: feed_item["title"],
      claim_review_body: Nokogiri.parse(feed_item["content"]).text,
      claim_review_image_url: feed_item["thumbnail"],
      claim_review_result: feed_item["title"].split(":").first,
      claim_review_url: feed_item["link"],
      raw_claim_review: feed_item
    }
  end
end
