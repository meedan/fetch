# frozen_string_literal: true

# Parser for https://www.newtral.es
require_relative('newtral_fakes')
class NewtralFactCheck < NewtralFakes
  include PaginatedReviewClaims
  def relevant_sitemap_subpath
    "www.newtral.es/factcheck"
  end
end
