# frozen_string_literal: true

# Parser for https://noticias.uol.com.br
class UOLEleicoesUltima < UOLComprova
  include PaginatedReviewClaims
  def fact_list_path(next_page=nil)
    "/eleicoes/ultimas/?next=#{next_page}"
  end

  def url_extraction_search
    "div.collection-standard section.latest-news-banner div.container section.results-index div.thumbnails-item a"
  end
end