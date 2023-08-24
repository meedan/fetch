# frozen_string_literal: true

# Parser for https://factcheckhindi.afp.com, subclass of AFP's parser
require_relative('afp')
class AFPFactCheckHindi < AFP
  include PaginatedReviewClaims
  def self.deprecated
    true
  end

  def hostname
    'https://factcheckhindi.afp.com'
  end

  def parse_raw_claim_review(raw_claim_review)
    parsed = super(raw_claim_review)
    parsed[:claim_review_body] = raw_claim_review["page"].search("article div.article-entry h3").text
    parsed
  end
end
