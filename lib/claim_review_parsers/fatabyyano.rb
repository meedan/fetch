# frozen_string_literal: true

# Parser for https://fatabyyano.net/fake_news/
class Fatabyyano < ClaimReviewParser
  include PaginatedReviewClaims
  def self.deprecated
    true
  end
  
  def hostname
    'https://fatabyyano.net'
  end

  def request_fact_page(page)
    post_url(
      self.hostname+"/wp-admin/admin-ajax.php",
      URI.encode_www_form(fact_page_params(page))
    )
  end

  def fact_page_params(page)
    {
      "action" => "us_ajax_grid",
      "ajax_url" => "https://fatabyyano.net/wp-admin/admin-ajax.php",
      "infinite_scroll" => "0",
      "max_num_pages" => "246",
      "pagination" => "ajax",
      "permalink_url" => "https://fatabyyano.net/fake_news",
      "template_vars" => "{\"columns\":\"3\",\"exclude_items\":\"none\",\"img_size\":\"default\",\"ignore_items_size\":false,\"items_layout\":\"25771\",\"items_offset\":\"1\",\"load_animation\":\"none\",\"overriding_link\":\"none\",\"post_id\":26144,\"query_args\":{\"post_type\":[\"post\"],\"tax_query\":[{\"taxonomy\":\"category\",\"field\":\"slug\",\"terms\":[\"fatabyyano_news\",\"social_related_rumors\",\"technological_related_rumors\",\"religious_related_rumors\",\"%d8%b1%d9%8a%d8%a7%d8%b6%d8%a9\",\"politics_related_rumors\",\"medical-rumors\",\"science_related_rumors\",\"fatabyyano_videos\",\"fatabyyano_articles\",\"covid19_updates\"]}],\"post_status\":[\"publish\",\"acf-disabled\"],\"post__not_in\":[26144],\"posts_per_page\":\"9\",\"paged\":#{page}},\"orderby_query_args\":{\"orderby\":{\"date\":\"DESC\"}},\"type\":\"grid\",\"us_grid_ajax_index\":1,\"us_grid_filter_params\":null,\"us_grid_index\":1,\"_us_grid_post_type\":\"post\"}"
    }
  end

  def parsed_fact_list_page(page)
    Nokogiri.parse(
      "<html><body>"+request_fact_page(page)+"</body></html>"
    )
  end

  def url_extraction_search
    "div.post_image a"
  end

  def url_extractor(atag)
    atag.attributes['href'].value
  end

  def safe_extract_ld_json_script_block(raw_claim_review)
    cr = extract_ld_json_script_block(raw_claim_review["page"], 1)
    cr && cr.first || {}
  end

  def parse_raw_claim_review(raw_claim_review)
    ld_json_obj = extract_ld_json_script_block(raw_claim_review["page"], 0)
    claim_review = safe_extract_ld_json_script_block(raw_claim_review)
    person = ld_json_obj["@graph"].select{|x| x["@type"] == "Person"}.first || {}
    blockquote = raw_claim_review["page"].search("blockquote")
    {
      id: raw_claim_review['url'],
      created_at: Time.parse(og_date_from_raw_claim_review(raw_claim_review)),
      author: person["name"],
      author_link: person["url"],
      claim_review_headline: og_title_from_raw_claim_review(raw_claim_review).split(" - ").first,
      claim_review_body: raw_claim_review["page"].search("div.wpb_wrapper h3").collect(&:text).reject(&:empty?).first,
      claim_review_image_url: claim_review_image_url_from_raw_claim_review(raw_claim_review),
      claim_review_reviewed: claim_review && claim_review["claimReviewed"] || blockquote && blockquote.first && blockquote.first.text.strip,
      claim_review_result: claim_review && claim_review["reviewRating"] && claim_review["reviewRating"]["alternateName"],
      claim_review_result_score: claim_result_score_from_raw_claim_review(claim_review),
      claim_review_url: raw_claim_review['url'],
      raw_claim_review: ld_json_obj
    }
  end
end