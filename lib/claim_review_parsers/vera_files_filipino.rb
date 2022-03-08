# frozen_string_literal: true

# Parser for https://verafiles.org/specials/fact-check-filipino
class VeraFilesFilipino < VeraFiles
  include PaginatedReviewClaims
  def fact_list_path(page = 1)
    "/specials/fact-check-filipino?ccm_paging_p=#{page}"
  end
end
