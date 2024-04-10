# frozen_string_literal: true

# Parser for https://www.vishvasnews.com
class VishvasNewsEnglish < VishvasNews
  include PaginatedReviewClaims
  def self.deprecated
    true
  end

  def fact_page_params(page)
    {
      action: "ajax_pagination",
      query_vars: "[]",
      page:  (page-1).to_s,
      loadPage: "file-latest-posts-part",
      lang: "english"
    }
  end

end
