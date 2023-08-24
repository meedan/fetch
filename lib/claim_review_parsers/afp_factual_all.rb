# frozen_string_literal: true

# Parser for https://factual.afp.com, subclass of AFP's parser
require_relative('afp')
class AFPFactualAll < AFP
  include PaginatedReviewClaims
  def self.deprecated
    true
  end

  def hostname
    'https://factual.afp.com/list/all/all/all/38560/44'
  end

  def url_extractor(atag)
    hostname.split("/list").first + atag.attributes['href'].value
  end

  def parse_raw_claim_review(raw_claim_review)
    parsed = super(raw_claim_review)
    parsed[:claim_review_body] = raw_claim_review["page"].search("article div.article-entry h3").text
    parsed
  end
end
