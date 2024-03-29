# frozen_string_literal: true

# Parser for https://www.thip.media
class Thip < ClaimReviewParser
  attr_accessor :raw_response
  include PaginatedReviewClaims
  def self.deprecated
    true
  end

  def initialize(cursor_back_to_date = nil, overwrite_existing_claims = false, send_notifications = true)
    super(cursor_back_to_date, overwrite_existing_claims, send_notifications)
    @fact_list_page_parser = 'json'
    @raw_response = {}
  end

  def get_new_fact_page_urls(page)
    response = get_fact_page_urls(page)
    existing_urls = get_existing_urls(response.collect{|d| d["link"]})
    response.select{|d| !existing_urls.include?(d["link"])}
  end

  def parsed_fact_page(fact_page_response)
    [fact_page_response["link"], parse_raw_claim_review(QuietHashie[{ raw_response: fact_page_response, url: fact_page_response["link"] }])]
  end

  def hostname
    "https://www.thip.media"
  end

  def fact_list_path(page = 1)
    "/wp-json/wp/v2/posts?categories=27,28,162,164,166,168,1886,1994,520&per_page=100&page=#{page}"
  end

  def url_extractor(response)
    response
  end

  def get_headline(raw_claim_review)
    if raw_claim_review["raw_response"]["yoast_head_json"]["title"].empty?
        raw_claim_review["raw_response"]["title"]["rendered"].include?("THIP Media") ? raw_claim_review["raw_response"]["title"]["rendered"].split(/ &ndash; | - /)[0..-2].join(" ") : raw_claim_review["raw_response"]["yoast_head_json"]["title"]
    else
      raw_claim_review["raw_response"]["yoast_head_json"]["title"].include?("THIP Media") ? raw_claim_review["raw_response"]["yoast_head_json"]["title"].split(/ &ndash; | - /)[0..-2].join(" ") : raw_claim_review["raw_response"]["yoast_head_json"]["title"]
    end
  end

  def parse_raw_claim_review(raw_claim_review)
    parsed_page = Nokogiri.parse("<html>"+raw_claim_review["raw_response"]["content"]["rendered"]+"</html>")

    {
      id: raw_claim_review['url'],
      author: raw_claim_review["raw_response"]["author_meta"] && raw_claim_review["raw_response"]["author_meta"]["display_name"],
      author_link: raw_claim_review["raw_response"]["author_meta"] && raw_claim_review["raw_response"]["author_meta"]["author_link"],
      created_at: (Time.parse(raw_claim_review["raw_response"]["date"]) rescue nil),
      claim_review_headline: get_headline(raw_claim_review),
      claim_review_body: (parsed_page.search("div.wp-block-media-text").first.text.strip rescue parsed_page.text),
      claim_review_image_url: raw_claim_review["raw_response"]["featured_img"],
      claim_review_result: parsed_page.search("p.has-regular-font-size strong").text.gsub(".", ""),
      claim_review_url: raw_claim_review['url'],
      raw_claim_review: raw_claim_review["raw_response"],
    }
  end
end
