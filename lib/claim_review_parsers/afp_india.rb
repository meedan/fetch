# frozen_string_literal: true

# Parser for https://faktencheck.afp.com, subclass of AFP's parser
require_relative('afp')
class AFPIndia < AFP
  include PaginatedReviewClaims
  def hostname
    'https://factcheck.afp.com/afp-india'
  end

  def fact_list_path(page = 1)
    # appears to be zero-indexed
    "?page=#{page - 1}"
  end

  def get_text_blocks(raw_claim_review)
    raw_claim_review["page"].search("article div.article-entry p").collect(&:text)
  end

  def parse_raw_claim_review(raw_claim_review)
    parsed = super(raw_claim_review)
    parsed[:claim_review_body] = get_text_blocks(raw_claim_review)
    parsed
  end
end
