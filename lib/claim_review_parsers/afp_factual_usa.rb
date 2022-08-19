# frozen_string_literal: true

# Parser for https://factual.afp.com, subclass of AFP's parser
require_relative('afp')
class AFPFactualUsa < AFP
  include PaginatedReviewClaims
  def hostname
    'https://factual.afp.com/afp-usa'
  end

  def url_extractor(atag)
    hostname.split("/afp-usa").first + atag.attributes['href'].value
  end

  def parse_raw_claim_review(raw_claim_review)
    parsed = super(raw_claim_review)
    parsed[:claim_review_body] = raw_claim_review["page"].search("article div.article-entry h3").text
    parsed
  end
end
