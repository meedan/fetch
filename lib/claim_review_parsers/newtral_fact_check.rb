# frozen_string_literal: true

# Parser for https://www.newtral.es
require_relative('newtral_fakes')
class NewtralFactCheck < NewtralFakes
  include PaginatedReviewClaims
  def fact_list_path(page = 1)
    "/wp-json/nwtfmg/v1/claim-reviews?page=#{page}&posts_per_page=15&firstDate=2018-01-01&lastDate=#{Time.now.strftime("%Y-%m-%d")}"
  end
end
