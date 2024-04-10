# frozen_string_literal: true

# Parser for https://www.vishvasnews.com
class VishvasNews < ClaimReviewParser
  include PaginatedReviewClaims
  def self.deprecated
    true
  end

  def hostname
    'https://www.vishvasnews.com'
  end

  def request_fact_page(page)
    post_url(
      self.hostname+"/wp-admin/admin-ajax.php",
      URI.encode_www_form(fact_page_params(page))
    )
  end

  def fact_page_params(page)
    {
      action: "ajax_pagination",
      query_vars: "[]",
      page:  (page-1).to_s,
      loadPage: "file-latest-posts-part"
    }
  end

  def parsed_fact_list_page(page)
    Nokogiri.parse(
      "<html><body>"+request_fact_page(page)+"</body></html>"
    )
  end

  def url_extraction_search
    "ul div.imagebox a"
  end

  def url_extractor(atag)
    atag.attributes['href'].value
  end

  def get_claim_review_rating_from_claim_review(claim_review)
    claim_review &&
    claim_review["reviewRating"] &&
    claim_review["reviewRating"]["alternateName"] &&
    claim_review["reviewRating"]["alternateName"].strip
  end

  def get_title_from_raw_claim_review(raw_claim_review)
    title = og_title_from_raw_claim_review(raw_claim_review).split(" - ")[0..-2].join(" - ")
    title = raw_claim_review["page"].search("title").text.split(" - ")[0..-2].join(" - ") if title.to_s.empty?
    title
  end

  def parse_raw_claim_review(raw_claim_review)
    claim_review = extract_ld_json_script_block(raw_claim_review["page"], 0) || {}
    {
      id: raw_claim_review["url"].to_s,
      created_at: claim_review["datePublished"] && Time.parse(claim_review["datePublished"]),
      author: claim_review["author"] && claim_review["author"]["name"],
      author_link: claim_review["author"] && claim_review["author"]["url"],
      claim_review_headline: get_title_from_raw_claim_review(raw_claim_review),
      claim_review_body: raw_claim_review["page"].search("div.lhs-area div.view-full p").first.children.last.text.split(":")[1..-1].to_a.join(":").strip,
      claim_review_reviewed: claim_review["claimReviewed"],
      claim_review_image_url: get_og_image_url(raw_claim_review),
      claim_review_result: get_claim_review_rating_from_claim_review(claim_review),
      claim_review_result_score: claim_result_score_from_raw_claim_review(claim_review),
      claim_review_url: raw_claim_review['url'],
      raw_claim_review: claim_review
    }
  end
end
