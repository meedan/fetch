# frozen_string_literal: true

# Parser for https://factcheck.afp.com
class Telemundo < ClaimReviewParser
  include PaginatedReviewClaims
  def initialize(cursor_back_to_date = nil, overwrite_existing_claims=false, send_notifications = true)
    cursor_back_to_date ||= Time.now-60*60*24*7 #looks like their pagination just loops back to other stories, breaking our iteration completion logic. Override to short window when not specified.
    super(cursor_back_to_date, overwrite_existing_claims, send_notifications)
  end

  def hostname
    'https://www.telemundo.com'
  end

  def fact_list_path(page = 1)
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

  def get_claim_review_author_value(claim_review, key_name)
    claim_review && claim_review["author"] && claim_review["author"][0] && claim_review["author"][0][key_name]
  end

  def parse_raw_claim_review(raw_claim_review)
    best_schema_object_available = JSON.parse(extract_all_ld_json_script_blocks(raw_claim_review["page"]).select{|x| JSON.parse(x).keys.include?("headline") rescue nil}.first)
    latest_timestamp = [(Time.parse(claim_review["datePublished"]) rescue nil), og_timestamps_from_raw_claim_review(raw_claim_review)].compact.flatten.sort.last
    {
      id: raw_claim_review['url'],
      created_at: latest_timestamp,
      author: get_claim_review_author_value(best_schema_object_available, "name"),
      author_link: get_claim_review_author_value(best_schema_object_available, "id"),
      claim_review_headline: best_schema_object_available["headline"],
      claim_review_body: best_schema_object_available["description"] || claim_review_body_from_raw_claim_review(raw_claim_review),
      claim_review_image_url: claim_review_image_url_from_raw_claim_review(raw_claim_review),
      claim_review_url: raw_claim_review['url'],
      raw_claim_review: best_schema_object_available
    }
  end
end
