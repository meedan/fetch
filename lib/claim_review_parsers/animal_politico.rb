# frozen_string_literal: true

# Parser for https://www.animalpolitico.com/sabueso/?seccion=discurso
class AnimalPolitico < ClaimReviewParser
  include PaginatedReviewClaims

  def front_page_urls
    [
      "https://www.animalpolitico.com/sabueso/?seccion=discurso",
      "https://www.animalpolitico.com/sabueso/?seccion=falsas",
      "https://www.animalpolitico.com/sabueso/?seccion=explainers"
    ]
  end

  def get_front_page(url)
    Nokogiri.parse(get_url(url).body.split("<!DOCTYPE html>")[1])
  end

  def get_urls(url)
    get_front_page(url).search("div.ap_sabueso_post a").collect{|x| x.attributes["href"].value}.uniq
  end

  def get_all_urls
    front_page_urls.collect{|u| get_urls(u)}.flatten.compact.uniq
  end
  
  def get_claim_reviews
    all_urls = get_all_urls
    existing_urls = get_existing_urls(all_urls)
    process_claim_reviews(get_parsed_fact_pages_from_urls(all_urls-existing_urls))
  end

  def parse_raw_claim_review(raw_claim_review)
    claim_review = extract_ld_json_script_block(raw_claim_review["page"], 1) || {}
    {
      id: raw_claim_review["url"],
      created_at: (Time.parse(og_date_from_raw_claim_review(raw_claim_review)) rescue nil),
      author: claim_review && claim_review["author"] && claim_review["author"]["name"],
      claim_review_headline: og_title_from_raw_claim_review(raw_claim_review),
      claim_review_body: raw_claim_review["page"].search("div.ap_single_first_excerpt").text,
      claim_review_reviewed: claim_review && claim_review["claimReviewed"],
      claim_review_image_url: get_og_image_url(raw_claim_review),
      claim_review_result: claim_review && claim_review["reviewRating"] && claim_review["reviewRating"]["alternateName"],
      claim_review_result_score: claim_result_score_from_raw_claim_review(claim_review),
      claim_review_url: raw_claim_review["url"],
      raw_claim_review: claim_review
    }
  end
end
