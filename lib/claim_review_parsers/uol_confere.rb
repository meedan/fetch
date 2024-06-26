# frozen_string_literal: true

# Parser for https://noticias.uol.com.br
class UOLConfere < UOLComprova
  include PaginatedReviewClaims
  def self.deprecated
    true
  end

  def self.interevent_time
    60*5
  end

  def fact_list_path(next_page=nil)
    "/confere/?next=#{next_page}"
  end

  def url_extraction_search
    "div.collection-standard section.latest-news-banner div.container section.results-index div.thumbnails-item a"
  end
end
