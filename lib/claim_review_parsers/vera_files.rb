# frozen_string_literal: true

# Parser for https://verafiles.org/specials/fact-check
class VeraFiles < ClaimReviewParser
  include PaginatedReviewClaims
  def initialize(cursor_back_to_date = nil, overwrite_existing_claims=false, send_notifications = true)
    super(cursor_back_to_date, overwrite_existing_claims, send_notifications)
    @proxy = Settings.get("static_ip_proxy_url")
  end

  def hostname
    'https://verafiles.org'
  end

  def fact_list_path(page = 1)
    "/specials/fact-check?ccm_paging_p=#{page}"
  end

  def url_extraction_search
    'figure a'
  end

  def url_extractor(atag)
    atag.attributes['href'].value.include?("/articles/") ? atag.attributes['href'].value : nil
  end

  def parse_raw_claim_review(raw_claim_review)
    {
      id: raw_claim_review['url'],
      created_at: Time.parse(og_date_from_raw_claim_review(raw_claim_review)),
      author: raw_claim_review["page"].search("div.entry-meta span#article_author")[-1].text,
      claim_review_headline: raw_claim_review["page"].search("article h1.article_title").text,
      claim_review_body: raw_claim_review["page"].search("article div.entry-content p").collect(&:text).join(" "),
      claim_review_image_url: value_from_og_tag(search_for_og_tags(raw_claim_review["page"], ["og:image"])),
      claim_review_url: raw_claim_review['url']
    }
  end
end
