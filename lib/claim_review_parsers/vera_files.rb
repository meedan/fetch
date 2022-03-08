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
    'div.collection__main div.page-list-article div.page-list-article__title a'
  end

  def url_extractor(atag)
    hostname + atag.attributes['href'].value
  end

  def parse_raw_claim_review(raw_claim_review)
    {
      id: raw_claim_review['url'],
      created_at: Time.parse(raw_claim_review["page"].search("div.article__date p")[-1].text),
      author: raw_claim_review["page"].search("div.article__author p")[-1].text,
      claim_review_headline: raw_claim_review["page"].search("section.article__title h1").text,
      claim_review_body: raw_claim_review["page"].search("main.article__main p").collect(&:text).join(" "),
      claim_review_image_url: value_from_og_tag(search_for_og_tags(raw_claim_review["page"], ["og:image"])),
      claim_review_url: raw_claim_review['url']
    }
  end
end
