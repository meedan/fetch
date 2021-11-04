# frozen_string_literal: true

# Parser for http://hindi.boomlive.in/ - does not follow standard Pagination scheme from PaginatedReviewClaims!
class HindiBoomLive < ClaimReviewParser
  include PaginatedReviewClaims
  def hostname
    'http://hindi.boomlive.in'
  end

  def fact_list_path(page = 1)
    # appears to be zero-indexed
    "/fast-check/#{page}"
  end

  def url_extraction_search
    'main#main div.category-articles-list h2.entry-title a'
  end

  def url_extractor(atag)
    hostname + atag.attributes['href'].value
  end

  def parse_raw_claim_review(raw_claim_review)
    article = extract_ld_json_script_block(raw_claim_review["page"], 0)
    {
      id: raw_claim_review["url"],
      created_at: Time.parse(article['datePublished']||og_date_from_raw_claim_review(raw_claim_review)),
      author: article["author"]["name"],
      author_link: hostname+article["author"]["url"],
      claim_review_headline: article["claimReviewed"],
      claim_review_body: raw_claim_review["page"].search("div.short-factcheck-snippet").text,
      claim_review_reviewed: article["itemReviewed"]["name"],
      claim_review_image_url: article["image"]["contentUrl"],
      claim_review_result: article["reviewRating"]["alternateName"],
      claim_review_result_score: claim_result_score_from_raw_claim_review(article["reviewRating"]),
      claim_review_url: raw_claim_review['url'],
      raw_claim_review: article
    }
  end
end
