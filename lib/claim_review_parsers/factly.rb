# frozen_string_literal: true

# Parser for https://factly.in
class Factly < ClaimReviewParser
  include PaginatedReviewClaims
  def self.deprecated
    true
  end

  def initialize(cursor_back_to_date = nil, overwrite_existing_claims=false, send_notifications = true)
    super(cursor_back_to_date, overwrite_existing_claims, send_notifications)
    @fact_list_page_parser = 'json'
  end

  def get_new_fact_page_urls(page)
    response = get_fact_page_urls(page)
    existing_urls = get_existing_urls(response.collect{|d| d["link"]})
    response.select{|d| !existing_urls.include?(d["link"])}
  end

  def parsed_fact_page(fact_page_response)
    parsed_page = parsed_page_from_url(fact_page_response["link"])
    return if parsed_page.nil?
    fact_page_response.delete("_links")
    [fact_page_response["link"], parse_raw_claim_review(QuietHashie[{ raw_response: fact_page_response, page: parsed_page, url: fact_page_response["link"] }])]
  end

  def hostname
    'https://factly.in'
  end

  def fact_list_path(page = 1)
    "/wp-json/wp/v2/posts?page=#{page}"
  end

  def fact_check_categories
    [357, 305]
  end

  def url_extractor(response)
    response.select{|r| (r["categories"]&fact_check_categories).length > 0}
  end

  def get_fact_index_from_page(page)
    bold_blockquotes = page.search('div.post-content blockquote p strong')
    found = bold_blockquotes.each_with_index.to_a.reverse.find { |x, _i| x.text.downcase.include?('fact') || x.text.downcase.include?('ఫాక్ట్')}
    [found && found.last, bold_blockquotes]
  end

  def get_claim_result_from_page(page)
    fact_result = nil
    fact_index, bold_blockquotes = get_fact_index_from_page(page)
    fact_result = bold_blockquotes[fact_index + 1].text.strip.gsub(".", "") if fact_index and bold_blockquotes and bold_blockquotes[fact_index + 1]
    return fact_result
  end

  def get_from_blockquote(page, terms)
    page.search('div.post-content blockquote p').select{|x| terms.collect{|t| x.text.downcase.include?(t)}.include?(true)}
  end

  def get_claim_reviewed_from_page(page)
    get_from_blockquote(page, ["claim", "క్లెయిమ్"]).first.children.last.text
  end

  def get_body_from_page(page)
    get_from_blockquote(page, ["fact", "ఫాక్", "ఫ్యాక్ట్"]).first.children[1..-1].text rescue nil
  end

  def person_from_schema_object(schema_object)
    schema_object["@graph"].select{|x| x["@type"] == "Person"}.first
  end

  def author_from_raw_claim_review_and_schema_object(raw_claim_review, schema_object)
    person = person_from_schema_object(schema_object)
    raw_claim_review['raw_response'] && 
    raw_claim_review['raw_response']['author_meta'] &&
    raw_claim_review['raw_response']['author_meta']['display_name'] ||
    person && person["name"]
  end

  def author_link_from_raw_claim_review_and_schema_object(raw_claim_review, schema_object)
    person = person_from_schema_object(schema_object)
    raw_claim_review['raw_response'] && 
    raw_claim_review['raw_response']['author_meta'] &&
    raw_claim_review['raw_response']['author_meta']['author_link'] ||
    person && person["@id"]
  end

  def parse_raw_claim_review(raw_claim_review)
    article = extract_ld_json_script_block(raw_claim_review["page"], -1)
    schema_object = extract_ld_json_script_block(raw_claim_review["page"], 0)
    {
      id: raw_claim_review['url'],
      created_at: Time.parse(raw_claim_review['raw_response']['date']),
      author: author_from_raw_claim_review_and_schema_object(raw_claim_review, schema_object),
      author_link: author_link_from_raw_claim_review_and_schema_object(raw_claim_review, schema_object),
      claim_review_headline: raw_claim_review['raw_response']['title']['rendered'],
      claim_review_body: get_body_from_page(raw_claim_review['page']),
      claim_review_reviewed: get_claim_reviewed_from_page(raw_claim_review['page']),
      claim_review_image_url: claim_review_image_url_from_raw_claim_review(raw_claim_review),
      claim_review_result: get_claim_result_from_page(raw_claim_review['page']),
      claim_review_result_score: nil,
      claim_review_url: raw_claim_review['url'],
      raw_claim_review: {article: article, api_response: raw_claim_review['raw_response']}
    }
  end
end
