# frozen_string_literal: true

# Parser for https://factcheck.afp.com
class AFP < ClaimReviewParser
  include PaginatedReviewClaims
  def hostname
    'https://factcheck.afp.com'
  end

  def fact_list_path(page = 1)
    # appears to be zero-indexed
    "/list?page=#{page - 1}"
  end

  def url_extraction_search
    'main.container div.card a'
  end

  def url_extractor(atag)
    hostname + atag.attributes['href'].value
  end
  def claim_review_headline_from_raw_claim_review_and_claim_review(raw_claim_review, claim_review)
    title = raw_claim_review['page'].search('h1.content-title').text.strip
    title = claim_review["@graph"][0]["name"] if title.empty?
    title
  end

  def parse_raw_claim_review(raw_claim_review)
    claim_review = extract_ld_json_script_block(raw_claim_review["page"], 0)
    {
      id: raw_claim_review['url'],
      created_at: Time.parse(claim_review["@graph"][0]["datePublished"]),
      author: claim_review["@graph"][0]["author"]["name"],
      author_link: claim_review["@graph"][0]["author"]["url"],
      claim_review_headline: claim_review_headline_from_raw_claim_review_and_claim_review(raw_claim_review, claim_review),
      claim_review_body: claim_review["@graph"][0]["name"],
      claim_review_reviewed: claim_review["@graph"][0]["claimReviewed"],
      claim_review_image_url: claim_review_image_url_from_raw_claim_review(raw_claim_review),
      claim_review_result: claim_review["@graph"][0]["reviewRating"]["alternateName"],
      claim_review_result_score: claim_result_score_from_raw_claim_review(claim_review["@graph"][0]),
      claim_review_url: raw_claim_review['url'],
      raw_claim_review: claim_review
    }
  end
end
