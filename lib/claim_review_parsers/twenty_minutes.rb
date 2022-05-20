# frozen_string_literal: true

# Parser for https://www.20minutes.fr/
class TwentyMinutes < ClaimReviewParser
  attr_accessor :raw_response
  include PaginatedReviewClaims
  def initialize(cursor_back_to_date = nil, overwrite_existing_claims=false, send_notifications = true)
    super(cursor_back_to_date, overwrite_existing_claims, send_notifications)
    @fact_list_page_parser = 'html_first_then_json'
    @raw_response = {}
  end

  def get_new_fact_page_urls(page)
    urls = get_fact_page_urls(page).collect{|x| x.include?("20minutes.fr") ? x : hostname+x}
    urls-get_existing_urls(urls)
  end

  def hostname
    'https://www.20minutes.fr'
  end

  def fact_list_path(page = nil)
    #doesn't respond to any number, only these precise ones with this pattern!
    if page == 1
      return "/societe/desintox/"
    elsif page == 2
      return "/v-ajax/tag/38000456/10"
    else
      return "/v-ajax/tag/38000456/#{((page-2)*10+10)-1}"
    end
  end

  def url_extractor(response)
    if response.class == Hash
      response["contents"].collect{|a| nokogiri_parse(a["content"]).search("a").first.attributes["href"].value rescue nil}.compact #looks like one element is an ad placement, so skip and compact
    else #assume its first page noko doc
      response.search("div.lt-jakku div.lt-jakku-main article a").collect{|a| self.hostname+(a.attributes["href"].value rescue nil).to_s}
    end
  end

  def parse_raw_claim_review(raw_claim_review)
    article = extract_ld_json_script_block(raw_claim_review["page"], 0)
    claim_review = extract_ld_json_script_block(raw_claim_review["page"], 4)
    {
      id: raw_claim_review["url"],
      created_at: get_created_at_from_article(article),
      author: article["author"] && article["author"]["name"],
      author_link: article["author"] && article["author"]["url"] && article["author"]["url"].class == Array ? article["author"]["url"][0] : article["author"]["url"],
      claim_review_headline: article["headline"],
      claim_review_body: article["description"],
      claim_review_reviewed: claim_review && claim_review["claimReviewed"],
      claim_review_image_url: og_image_url_from_raw_claim_review(raw_claim_review),
      claim_review_result: claim_review && claim_review["reviewRating"] && claim_review["reviewRating"]["alternateName"],
      claim_review_result_score: claim_result_score_from_raw_claim_review(claim_review || {}),
      claim_review_url: raw_claim_review['url'],
      raw_claim_review: {article: article, claim_review: claim_review}
    }
  end
end