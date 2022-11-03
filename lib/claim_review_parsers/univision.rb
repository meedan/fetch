# frozen_string_literal: true

# Parser for https://syndicator.univision.com
class Univision < ClaimReviewParser
  include PaginatedReviewClaims
  def initialize(cursor_back_to_date = nil, overwrite_existing_claims=false, send_notifications = true)
    super(cursor_back_to_date, overwrite_existing_claims, send_notifications)
    @fact_list_page_parser = 'json'
  end

  def hostname
    'https://syndicator.univision.com'
  end

  def fact_list_path(page = 1, limit=20)
    "/web-api/widget?wid=$-719170345&offset=#{(page-1)*limit}&limit=#{limit}&url=https://www.univision.com/temas/detector-de-mentiras&mrpts=1667232059000"
  end

  def url_extractor(response)
    response["data"]["widget"]["contents"].collect{|x| x["uri"]}
  end

  def get_time_from_raw_claim_review(raw_claim_review)
    ["datePublished", "dateUpdated"].collect{|key|
      Time.parse(raw_claim_review["page"].search("meta[@itemprop='#{key}']").first.attributes["content"].value) rescue nil
    }.flatten.sort.first
  end

  def parse_raw_claim_review(raw_claim_review)
    {
      id: raw_claim_review['url'],
      created_at: get_time_from_raw_claim_review(raw_claim_review),
      author: raw_claim_review["page"].search("span[@itemprop='name'] a span").text,
      author_link: "https://www.univision.com/equipo",
      claim_review_headline: og_title_from_raw_claim_review(raw_claim_review),
      claim_review_body: nil,
      claim_review_image_url: get_og_image_url(raw_claim_review),
      claim_review_result: nil,
      claim_review_result_score: nil,
      claim_review_url: nil,
      raw_claim_review: {article: article}
    }
  end
end