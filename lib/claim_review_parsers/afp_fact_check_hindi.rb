# frozen_string_literal: true

# Parser for https://factcheckhindi.afp.com, subclass of AFP's parser
require_relative('afp')
class AFPFactCheckHindi < AFP
  include PaginatedReviewClaims
  def hostname
    'https://factcheckhindi.afp.com'
  end
end
