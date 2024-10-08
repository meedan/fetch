# frozen_string_literal: true

# Parser for https://www.lasillavacia.com/la-silla-vacia/detector-de-mentiras/
class LaSillaVacia < ClaimReviewParser
  include PaginatedReviewClaims
  def self.deprecated
    true
  end

  def initialize(cursor_back_to_date = nil, overwrite_existing_claims=false, send_notifications = true)
    super(cursor_back_to_date, overwrite_existing_claims, send_notifications)
    @fact_list_page_parser = 'html_body_encased_html'
  end

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

  def max_pages
    30
  end

  def specifically_finished_iterating?(processed_claim_reviews, pages_since_last_hit)
    finished_iterating?(processed_claim_reviews) && pages_since_last_hit > max_pages
  end
  
  def get_claim_reviews
    page = 1
    pages_since_last_hit = 0
    processed_claim_reviews = store_claim_reviews_for_page(page)
    until specifically_finished_iterating?(processed_claim_reviews, pages_since_last_hit)
      page += 1
      pages_since_last_hit += 1
      processed_claim_reviews = store_claim_reviews_for_page(page)
      pages_since_last_hit = 0 if !processed_claim_reviews.empty?
    end
  end

  def claim_review_result_and_score_from_title_classes(title_classes)
    if title_classes.include?("border-scale-red")
      return [0.0, "False"]
    elsif title_classes.include?("border-scale-orange")
      return [0.25, "Mostly False"]
    elsif title_classes.include?("border-scale-yellow")
      return [0.5, "Debatable"]
    elsif title_classes.include?("border-scale-ligth-green")
      return [0.75, "Mostly True"]
    elsif title_classes.include?("border-scale-green")
      return [1.0, "True"]
    end
  end

  def parse_raw_claim_review(raw_claim_review)
    timestamp = Time.parse(raw_claim_review["page"].search("div.detector-article time.p").first.text.strip) rescue nil
    claim_review_result_score, claim_review_result = claim_review_result_and_score_from_title_classes(get_title_classes_from_raw_claim_review(raw_claim_review))
    result = {
      id: raw_claim_review['url'],
      created_at: timestamp,
      claim_review_headline: raw_claim_review["page"].search("div.detector-article h1.h2").text.strip,
      claim_review_body: raw_claim_review["page"].search("div#detector-pocasPalabras p").collect(&:text).collect(&:strip).join(" "),
      claim_review_image_url: og_image_url_from_raw_claim_review(raw_claim_review),
      claim_review_result: claim_review_result,
      claim_review_result_score: claim_review_result_score,
      claim_review_url: raw_claim_review['url'],
    }
    result[:claim_review_headline].to_s.empty? ? {} : result
  end
end
