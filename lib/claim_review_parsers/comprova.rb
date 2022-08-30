# frozen_string_literal: true

# Parser for https://projetocomprova.com.br/
class Comprova < ClaimReviewParser
  include PaginatedReviewClaims
  def hostname
    'https://projetocomprova.com.br'
  end

  def fact_list_path(page = 1)
    "/page/#{page}/"
  end

  def url_extraction_search
    'main.site-main article.answer a.answer__title__link'
  end

  def url_extractor(atag)
    atag.attributes["href"].value
  end
  
  def claim_review_result_from_raw_claim_review(raw_claim_review)
    raw_claim_review["page"].search("dt.answer__tag").text.strip
  end

  def claim_review_body_from_raw_claim_review(raw_claim_review)
    raw_claim_review["page"].search("dd.answer__tag__details").text.strip
  end
  
  def parse_raw_claim_review(raw_claim_review)
    claim_review = (extract_ld_json_script_block(raw_claim_review["page"], 1) || [{}]).first
    {
      id: raw_claim_review['url'],
      created_at: claim_review["datePublished"] && Time.parse(claim_review["datePublished"]) || og_date_from_raw_claim_review(raw_claim_review) && Time.parse(og_date_from_raw_claim_review(raw_claim_review)),
      author: claim_review["author"] && claim_review["author"]["name"],
      author_link: claim_review["author"] && claim_review["author"]["url"],
      claim_review_headline: og_title_from_raw_claim_review(raw_claim_review).gsub(" : Projeto Comprova", ""),
      claim_review_body: claim_review_body_from_raw_claim_review(raw_claim_review),
      claim_review_reviewed: claim_review["claimReviewed"],
      claim_review_image_url: value_from_og_tag(search_for_og_tags(raw_claim_review["page"], ["og:image"])),
      claim_review_result: claim_review_result_from_raw_claim_review(raw_claim_review),
      claim_review_result_score: claim_result_score_from_raw_claim_review(claim_review),
      claim_review_url: raw_claim_review['url'],
      raw_claim_review: claim_review
    }
  end
end