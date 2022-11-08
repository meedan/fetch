# frozen_string_literal: true

# Parser for https://verifica.efe.com
class EfeVerifica < ClaimReviewParser
  include PaginatedReviewClaims
  def hostname
    'https://verifica.efe.com'
  end

  def fact_list_path(page = 1)
    "/verificaciones/page/#{page}/"
  end

  def url_extraction_search
    'div.content div.post_header h3.post_title a'
  end

  def url_extractor(atag)
    atag.attributes['href'].value
  end

  def get_claim_review_from_raw_claim_review(raw_claim_review)
    claim_review = extract_ld_json_script_block(raw_claim_review["page"], 0)
    claim_review && claim_review[0]
  end

  def safe_created_at(claim_review, raw_claim_review)
    timestamp = claim_review["datePublished"] || og_date_from_raw_claim_review(raw_claim_review)
    timestamp && Time.parse(timestamp)
  end

  def parse_raw_claim_review(raw_claim_review)
    claim_review = get_claim_review_from_raw_claim_review(raw_claim_review)
    {
      id: raw_claim_review['url'],
      created_at: safe_created_at(claim_review, raw_claim_review),
      author: claim_review["author"]["name"],
      author_link: claim_review["author"]["url"],
      claim_review_headline: value_from_og_tags(raw_claim_review, ["og:title"]),
      claim_review_body: raw_claim_review["page"].search("blockquote").last.text,
      claim_review_reviewed: claim_review["claimReviewed"],
      claim_review_result: claim_review["reviewRating"] && claim_review["reviewRating"]["alternateName"],
      claim_review_result_score: claim_result_score_from_raw_claim_review(claim_review),
      claim_review_url: raw_claim_review['url'],
      raw_claim_review: claim_review
    }
  end
end
