# frozen_string_literal: true

# Parser for https://www.factcheck.org
class FactCheckOrg < ClaimReviewParser
  include PaginatedReviewClaims
  def self.includes_service_keyword
    true
  end

  def hostname
    'https://www.factcheck.org'
  end

  def fact_list_path(page = 1)
    "/page/#{page}/"
  end

  def url_extraction_search
    'div#content h3.entry-title a'
  end

  def url_extractor(atag)
    atag.attributes['href'].value
  end

  def og_timestamps_from_raw_claim_review(raw_claim_review)
    raw_claim_review["page"].search("meta").select{|x|
      x.attributes["property"] && x.attributes["property"].value.include?("_time")
    }.collect{|x|
      Time.parse(x.attributes["content"].value) rescue nil
    }.compact
  end

  def claim_review_headline_from_raw_claim_review_and_web_page_obj(raw_claim_review, web_page_obj)
    title = raw_claim_review['page'].search('h1.entry-title').text.strip
    title = web_page_obj["name"] if title.empty?
    title
  end

  def claim_review_body_from_raw_claim_review(raw_claim_review)
    body = get_claim_review_body_from_article_text(raw_claim_review)
    body = get_claim_review_body_from_og_description(raw_claim_review) if body.to_s.empty?
    body
  end

  def get_claim_review_body_from_article_text(raw_claim_review)
    raw_claim_review['page'].search("article p").collect(&:text).collect(&:strip).join(" ")
  end

  def get_claim_review_body_from_og_description(raw_claim_review)
    value_from_og_tags(raw_claim_review, ["og:description"])
  end

  def parse_raw_claim_review(raw_claim_review)
    claim_review = extract_ld_json_script_block(raw_claim_review["page"], 0)
    latest_timestamp = [Time.parse(claim_review["@graph"].select{|x| x.keys.include?("datePublished")}[0]["datePublished"]), og_timestamps_from_raw_claim_review(raw_claim_review)].flatten.sort.last
    web_page_obj = claim_review["@graph"].select{|x| x["@type"] == "WebPage"}[0]
    {
      id: raw_claim_review['url'],
      created_at: latest_timestamp,
      author: web_page_obj["author"]["name"] || "FactCheck.org",
      author_link: web_page_obj["author"]["url"] || web_page_obj["author"]["@id"],
      claim_review_headline: claim_review_headline_from_raw_claim_review_and_web_page_obj(raw_claim_review, web_page_obj),
      claim_review_body: claim_review_body_from_raw_claim_review(raw_claim_review),
      claim_review_image_url: claim_review_image_url_from_raw_claim_review(raw_claim_review),
      claim_review_url: raw_claim_review['url'],
      raw_claim_review: claim_review
    }
  end
end
