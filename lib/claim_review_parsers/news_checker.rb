# frozen_string_literal: true

# Parser for https://newschecker.in
class NewsChecker < ClaimReviewParser
  include PaginatedReviewClaims
  def hostnames
    [
      "https://newschecker.in",
      "https://newschecker.in/hi",
      "https://newschecker.in/gu",
      "https://newschecker.in/mr",
      "https://newschecker.in/pa",
      "https://newschecker.in/bh",
      "https://newschecker.in/ka",
      "https://newschecker.in/kn",
    ]
  end

  def fact_list_path(page = 1)
    "/page/#{page}"
  end

  def url_extraction_search
    'div.td-module-container .entry-title a'
  end

  def url_extractor(atag)
    atag.attributes['href'].value
  end

  def get_fact_page_urls(page)
    hostnames.collect{|hostname|
      extract_urls_from_html(
        nokogiri_parse(
          get_url(
            hostname + fact_list_path(page)
          )
        )
      )
    }.flatten.uniq
  end

  def get_claim_review_safely(raw_claim_review)
    claim_review = extract_ld_json_script_block(raw_claim_review["page"], 0)
    claim_review && claim_review[0] || {}
  end

  def parse_raw_claim_review(raw_claim_review)
    claim_review = get_claim_review_safely(raw_claim_review)
    {
      id: raw_claim_review['url'],
      created_at: (Time.parse(claim_review["datePublished"]) rescue nil),
      author: claim_review && claim_review["author"] && claim_review["author"]["name"],
      author_link: claim_review && claim_review["author"] && claim_review["author"]["url"],
      claim_review_headline: raw_claim_review["page"].search("h1.tdb-title-text").text,
      claim_review_image_url: get_og_image_url(raw_claim_review),
      claim_review_reviewed: claim_review["claimReviewed"],
      claim_review_result: claim_review["reviewRating"] && claim_review["reviewRating"]["alternateName"],
      claim_review_result_score: claim_result_score_from_raw_claim_review(claim_review),
      claim_review_url: raw_claim_review['url'],
      raw_claim_review: claim_review
    }
  end
end
