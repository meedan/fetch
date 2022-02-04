# frozen_string_literal: true

# Parser for https://factual.afp.com, subclass of AFP's parser
require_relative('afp')
class AFPFactuel < AFP
  include PaginatedReviewClaims
  def hostname
    'https://factuel.afp.com'
  end
end
