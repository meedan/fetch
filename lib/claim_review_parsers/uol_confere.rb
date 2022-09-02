# frozen_string_literal: true

# Parser for https://noticias.uol.com.br
class UOLConfere < UOLComprova
  include PaginatedReviewClaims
  def fact_list_path(next_page=nil)
    "/confere/?next=#{next_page}"
  end
end
