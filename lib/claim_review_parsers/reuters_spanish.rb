# frozen_string_literal: true

class ReutersSpanish < Reuters
  include PaginatedReviewClaims
  def hostname
    'https://www.reuters.com/fact-check/espanol'
  end

  def fact_list_path(page = 1)
    "/news/archive/factcheckspanishnew?view=page&page=#{page}&pageSize=10"
  end

end
