# frozen_string_literal: true

# Parser for https://faktencheck.afp.com, subclass of AFP's parser
require_relative('afp')
class AFPFaktencheck < AFP
  include PaginatedReviewClaims
  def self.interevent_time
    60*15
  end

  def hostname
    'https://faktencheck.afp.com'
  end

  def get_text_blocks(raw_claim_review)
    raw_claim_review["page"].search("article div.article-entry p").collect(&:text)
  end

  def get_index_for_conclusion_paragraph(raw_claim_review)
    raw_claim_review["page"].search("article div.article-entry p").collect(&:to_s).each_with_index.select{|h, i| h.include?("<strong>Fazit")}.last.last rescue 0
  end

  def parse_raw_claim_review(raw_claim_review)
    parsed = super(raw_claim_review)
    conclusion_index = get_index_for_conclusion_paragraph(raw_claim_review)
    parsed[:claim_review_body] = get_text_blocks(raw_claim_review)[conclusion_index..-1].join(" ").gsub("Fazit: ", "")
    parsed
  end
end
