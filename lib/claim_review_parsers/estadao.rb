# frozen_string_literal: true

require 'open-uri'

# Parser for https://www.estadao.com.br
class Estadao < ClaimReviewParser
  include PaginatedReviewClaims
  def initialize(cursor_back_to_date = nil, overwrite_existing_claims=false, send_notifications = true)
    super(cursor_back_to_date, overwrite_existing_claims, send_notifications)
    @fact_list_page_parser = 'json'
    @escape_url_in_request = false
    @version_number = get_current_d_version
  end

  def hostname
    'https://www.estadao.com.br'
  end

  def get_current_d_version
    # opens hostname url, searches for the following link:
    # <link rel="shortcut icon" href="/pf/resources/favicon.ico?d=556"/>
    # extracts the '556' value from the href attribute, returns that.
    # some functions you may want to use along your journey:
    # - get_url from ClaimReviewParser class
    # - Nokogiri.parse
    # - URI.parse
    # - CGI.parse
    
    doc = Nokogiri::HTML(URI.open("https://www.estadao.com.br"))
    number = doc.css("link[rel='shortcut icon']")[0].attributes['href'].value.chars.last(3).join

    # parsed_doc = Nokogiri.parse("https://www.estadao.com.br")
    # p parsed_doc

    return number
  end

  def fact_list_path(page = 1)
    # "/pf/api/v3/content/fetch/story-feed-query?query=#{URI.encode(fact_list_params(page).to_json)}&d=#{@version_number}&_website=estadao"
    "/pf/api/v3/content/fetch/story-feed-query?query=#{URI.encode(fact_list_params(page).to_json)}&d=557&_website=estadao"
  end

  def fact_list_params(page)
    {
      body: {
        query: {
          bool: {
            must: [
              { term: { type: 'story' } },
              { term: { 'revision.published': 1 } },
              { nested: { 'path': 'taxonomy.sections', query: { bool: { must: [{ regexp: { 'taxonomy.sections._id': '.*estadao-verifica.*' } }] } } } }
            ]
          }
        }
      }.to_json,
      size: ((page - 1) * 4),
      sort: 'display_date:desc, first_publish_date:desc'
    }
  end

  def url_extractor(response)
    response["content_elements"].collect{|x| hostname+x["canonical_url"].to_s}
  end
  
  def claim_review_image_url_from_claim_review_and_raw_page(claim_review, raw_claim_review)
    claim_review &&
    claim_review["image"] &&
    claim_review["image"]["url"] &&
    claim_review["image"]["url"][0] ||
    value_from_og_tags(raw_claim_review, ["og:image"])
  end

  def claim_review_result_from_claim_review(claim_review)
    claim_review &&
    claim_review["reviewRating"] &&
    claim_review["reviewRating"]["alternateName"]
  end
  
  def claim_review_body_from_raw_claim_review(raw_claim_review)
    raw_claim_review["page"].search("h2.n--noticia__subtitle").first.text rescue nil
  end

  def parse_raw_claim_review(raw_claim_review)
    claim_review = extract_ld_json_script_block(raw_claim_review["page"], 0) || {}
    {
      id: raw_claim_review['url'],
      created_at: claim_review["datePublished"] && Time.parse(claim_review["datePublished"]) || (claim_review["itemReviewed"] && claim_review["itemReviewed"]["datePublished"] && Time.parse(claim_review["itemReviewed"]["datePublished"])),
      author: raw_claim_review["page"].search("div.authors-info span.authors-names").first.text,
      claim_review_headline: value_from_og_tags(raw_claim_review, ["og:title"]),
      claim_review_body: claim_review_body_from_raw_claim_review(raw_claim_review) || value_from_og_tags(raw_claim_review, ["og:description"]),
      claim_review_reviewed: claim_review["claimReviewed"],
      claim_review_image_url: claim_review_image_url_from_claim_review_and_raw_page(claim_review, raw_claim_review),
      claim_review_result: claim_review_result_from_claim_review(claim_review),
      claim_review_result_score: claim_result_score_from_raw_claim_review(claim_review),
      claim_review_url: raw_claim_review['url'],
      raw_claim_review: claim_review
    }
  end
end

