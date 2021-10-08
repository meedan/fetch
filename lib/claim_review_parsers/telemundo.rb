# frozen_string_literal: true

# Parser for https://factcheck.afp.com
class Telemundo < ClaimReviewParser
  include PaginatedReviewClaims
  def hostname
    'https://www.telemundo.com'
  end

  def fact_list_path(page = 1)
    # appears to be zero-indexed
    "/noticias/t-verifica?page=#{page}"
  end

  def url_extraction_search
    'div.layout-container div.layout-grid-item article a'
  end

  def url_extractor(atag)
    atag.attributes['href'].value
  end

  def og_timestamps_from_raw_claim_review(raw_claim_review)
    raw_claim_review["page"].search("meta").select{|x|
      x.attributes["itemprop"] && x.attributes["itemprop"].value.downcase.include?("date")
    }.collect{|x|
      Time.parse(x.attributes["content"].value) rescue nil
    }.compact
  end

  def claim_review_body_from_raw_claim_review(raw_claim_review)
    raw_claim_review['page'].search("article p").collect(&:text).collect(&:strip).join(" ") rescue nil
  end

  def parse_raw_claim_review(raw_claim_review)
    claim_review = extract_ld_json_script_block(raw_claim_review["page"], 2)
    latest_timestamp = [Time.parse(claim_review["datePublished"]), og_timestamps_from_raw_claim_review(raw_claim_review)].flatten.sort.last
    {
      id: raw_claim_review['url'],
      created_at: latest_timestamp,
      author: claim_review["author"][0]["name"],
      author_link: claim_review["author"][0]["id"],
      claim_review_headline: claim_review["headline"],
      claim_review_body: claim_review_body_from_raw_claim_review(raw_claim_review) || claim_review["description"],
      claim_review_image_url: claim_review_image_url_from_raw_claim_review(raw_claim_review),
      claim_review_url: raw_claim_review['url'],
      raw_claim_review: claim_review
    }
  end
end
