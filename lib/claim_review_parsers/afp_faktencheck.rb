# frozen_string_literal: true

# Parser for https://faktencheck.afp.com, subclass of AFP's parser
require_relative('afp')
class AFPFaktencheck < AFP
  include PaginatedReviewClaims
  def hostname
    'https://faktencheck.afp.com'
  end
end
