# frozen_string_literal: true

# Parser for https://www.lasillavacia.com/la-silla-vacia/detector-de-mentiras/
class LaSillaVacia < ClaimReviewParser
  include PaginatedReviewClaims
  def hostname
    'https://www.lasillavacia.com'
  end

  def fact_list_path(page = 1)
    # appears to be zero-indexed
    "/elementAjax/SillaDetector/MasHistoriasRecientes?page=#{page}"
  end

  def url_extraction_search
    'a'
  end

  def url_extractor(atag)
    atag.attributes['href'].value
  end

  def get_title_classes_from_raw_claim_review(raw_claim_review)
    raw_claim_review["page"].search("div.detector-article h1.h2").first.attributes["class"].value
  end

  def claim_review_result_and_score_from_title_classes(title_classes)
    if title_classes.include?("border-scale-red")
      return [0.0, "False"]
    elsif title_classes.include?("border-scale-orange")
      return [0.33, "Mostly False"]
    elsif title_classes.include?("border-scale-ligth-green")
      return [0.66, "Mostly True"]
    elsif title_classes.include?("border-scale-green")
      return [1.0, "True"]
    end
  end

  def parse_raw_claim_review(raw_claim_review)
    timestamp = Time.parse(raw_claim_review["page"].search("div.detector-article time.p").first.text.strip) rescue nil
    claim_review_result, claim_review_result_score = claim_review_result_and_score_from_title_classes(get_title_classes_from_raw_claim_review(raw_claim_review))
    {
      id: raw_claim_review['url'],
      created_at: timestamp,
      claim_review_headline: raw_claim_review["page"].search("div.detector-article h1.h2").text.strip,
      claim_review_body: raw_claim_review["page"].search("div.detector-article div.mainInternalArticle__content p").collect(&:text).collect(&:strip).join(" "),
      claim_review_image_url: og_image_url_from_raw_claim_review(raw_claim_review),
      claim_review_result: claim_review_result,
      claim_review_result_score: claim_review_result_score,
      claim_review_url: raw_claim_review['url'],
    }
  end
end
