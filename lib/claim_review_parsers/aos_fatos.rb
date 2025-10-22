# frozen_string_literal: true

# Parser for https://www.aosfatos.org/noticias/checamos/
class AosFatos < ClaimReviewParser
  include PaginatedReviewClaims
  def self.deprecated
    true
  end

  def hostname
    'https://www.aosfatos.org'
  end

  def fact_list_path(page = 1)
    "/noticias/checamos/?page=#{page}"
  end

  def url_extraction_search
    'main section.container section.entry-list-container a.entry-content'
  end

  def url_extractor(atag)
    hostname+atag.attributes["href"].value
  end
  
  def claim_review_result_from_claim_review(claim_review)
    claim_review &&
    claim_review["reviewRating"] &&
    claim_review["reviewRating"]["alternateName"] && 
    claim_review["reviewRating"]["alternateName"].to_s.split(":").first
  end
  
  def claim_review_body_from_raw_claim_review(raw_claim_review)
    raw_claim_review["page"].search("main section.container article.ck-article p").select{|x| x.parent.name == "article"}.first.text.strip.gsub("(veja aqui)", "")
  end
  
  def find_claim_review_from_raw_claim_review(raw_claim_review)
    extract_all_ld_json_script_blocks(raw_claim_review["page"]).collect{|x| JSON.parse(x.text) rescue nil}.flatten.compact.select{|x| x["@type"].to_s.include?("ClaimReview")}.first
  end
  
  def parse_raw_claim_review(raw_claim_review)
    claim_review = find_claim_review_from_raw_claim_review(raw_claim_review)
    return {} if claim_review.nil?
    {
      id: raw_claim_review['url'],
      created_at: claim_review["datePublished"] && Time.parse(claim_review["datePublished"]),
      author: claim_review["author"] && claim_review["author"][0] && claim_review["author"][0]["name"],
      author_link: claim_review["author"] && claim_review["author"][0] && claim_review["author"][0]["url"],
      claim_review_headline: og_title_from_raw_claim_review(raw_claim_review).gsub(" | Aos Fatos", ""),
      claim_review_body: claim_review_body_from_raw_claim_review(raw_claim_review),
      claim_review_reviewed: claim_review["claimReviewed"],
      claim_review_image_url: get_og_image_url(raw_claim_review),
      claim_review_result: claim_review_result_from_claim_review(claim_review),
      claim_review_result_score: claim_result_score_from_raw_claim_review(claim_review),
      keywords: keywords_from_raw_claim_review(raw_claim_review),
      claim_review_url: raw_claim_review['url'],
      raw_claim_review: claim_review
    }
  end
end