# https://www.newtral.es/factcheck-sitemap.xml  2022-10-27 15:41 +00:00
# https://www.newtral.es/fake-sitemap.xml  2022-10-27 17:03 +00:00
# https://www.newtral.es/fake-sitemap2.xml  2022-08-04 07:22 +00:00
# https://www.newtral.es/fake-sitemap3.xml  2022-10-27 17:03 +00:00
# frozen_string_literal: true

# Parser for https://www.newtral.es
class NewtralFakes < ClaimReviewParser
  include PaginatedReviewClaims
  def initialize(cursor_back_to_date = nil, overwrite_existing_claims=false, send_notifications = true)
    super(cursor_back_to_date, overwrite_existing_claims, send_notifications)
    @per_article_sleep_time = 3
    @run_in_parallel = false
    @fact_list_page_parser = 'json'
  end
  def hostname
    'https://www.newtral.es'
  end

  def relevant_sitemap_subpath
    "www.newtral.es/fake"
  end

  def includes_relevant_path(url)
    url.include?(relevant_sitemap_subpath)
  end

  def get_sitemap_urls(url)
    Nokogiri.parse(get_url(url)).search("loc").collect(&:text)
  end

  def get_article_urls
    get_sitemap_urls(hostname+"/sitemap_index.xml").select{|url| includes_relevant_path(url)}.collect do |sitemap_url|
      get_sitemap_urls(sitemap_url)
    end.flatten
  end
  
  def get_new_article_urls
    page_urls = get_article_urls
    page_urls-page_urls.each_slice(200).collect{|subset| get_existing_urls(subset)}.flatten # paginate because page_urls can be *huge*
  end

  def get_claim_reviews
    process_claim_reviews(get_parsed_fact_pages_from_urls(get_new_article_urls))
  end

  def claim_review_body_from_raw_claim_review(raw_claim_review)
    raw_claim_review["page"].search("div.entry-content p")[1].text
  end

  def parse_raw_claim_review(raw_claim_review)
    ld_json_object = extract_ld_json_script_block(raw_claim_review["page"], 0)
    claim_review = ld_json_object["@graph"].select{|x| x["@type"]=="ClaimReview"}.first
    {
      id: raw_claim_review['url'],
      created_at: Time.parse(claim_review["datePublished"]),
      author: claim_review["author"]["name"],
      author_link: claim_review["author"]["url"],
      claim_review_headline: value_from_og_tags(raw_claim_review, ["og:title", "og:description"]),
      claim_review_body: claim_review_body_from_raw_claim_review(raw_claim_review),
      claim_review_image_url: get_og_image_url(raw_claim_review),
      claim_review_result: claim_review["reviewRating"] && claim_review["reviewRating"]["alternateName"],
      claim_review_result_score: claim_result_score_from_raw_claim_review(claim_review),
      claim_review_url: raw_claim_review['url'],
      raw_claim_review: {ld_json_object: ld_json_object}
    }
  end
end
