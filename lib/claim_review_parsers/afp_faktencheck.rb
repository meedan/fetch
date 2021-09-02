# frozen_string_literal: true

# Parser for https://faktencheck.afp.com, subclass of AFP's parser
require_relative('afp')
class AFPFaktencheck < AFP
  include PaginatedReviewClaims
  def hostname
    'https://faktencheck.afp.com'
  end

  def parse_raw_claim_review(raw_claim_review)
    parsed = super(raw_claim_review)
    parsed[:claim_review_headline] = (claim_review["@graph"][0]["claimReviewed"] || claim_review_headline_from_raw_claim_review_and_claim_review(raw_claim_review, claim_review))
    parsed
  end
end
