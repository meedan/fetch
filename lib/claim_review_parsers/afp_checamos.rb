# frozen_string_literal: true

# Parser for https://checamos.afp.com, subclass of AFP's parser
require_relative('afp')
class AFPChecamos < AFP
  include PaginatedReviewClaims
  def self.interevent_time
    60*15
  end

  def hostname
    'https://checamos.afp.com'
  end

  def get_image_url_for_raw_claim_review(raw_claim_review)
    hostname+raw_claim_review["page"].search("article div.article-entry img")[0].attributes["src"].value rescue nil
  end

  def parse_raw_claim_review(raw_claim_review)
    parsed = super(raw_claim_review)
    new_image_url = get_image_url_for_raw_claim_review(raw_claim_review)
    parsed[:claim_review_body] = raw_claim_review["page"].search("article div.article-entry h3").text
    parsed[:claim_review_image_url] = new_image_url if !new_image_url.nil?
    parsed
  end
end
