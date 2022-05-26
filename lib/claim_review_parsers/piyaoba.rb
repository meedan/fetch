# frozen_string_literal: true

# Parser for https://www.piyaoba.org
class Piyaoba < ClaimReviewParser
  include PaginatedReviewClaims
  def hostname
    'https://www.piyaoba.org'
  end

  def request_fact_page(page)
    RestClient::Request.execute(
      method: :post,
      url: self.hostname+"/wp-admin/admin-ajax.php",
      payload: "action=get_filter_posts&nonce=6916ff7a61&params%5Bpage%5D=#{page}&params%5Btax%5D=category&params%5Bpost-type%5D=post&params%5Bterm%5D=10%2C9%2C11&params%5Bper-page%5D=9&params%5Bfilter-id%5D=1612&params%5Bcaf-post-layout%5D=post-layout4&params%5Bdata-target-div%5D=.data-target-div1",
    )
  end

  def parsed_fact_list_page(page)
    Nokogiri.parse(
    "<html><body>"+JSON.parse(
        request_fact_page(page)
      )["content"].to_s+"</body></html>"
    )
  end

  def url_extraction_search
    "article div.first-column a"
  end

  def url_extractor(atag)
    atag.attributes['href'].value
  end

  def image_url_result_map
    {
      "https://www.piyaoba.org/wp-content/uploads/2021/11/GLight.png" => ["True", 1.0],
      "https://www.piyaoba.org/wp-content/uploads/2021/11/YLight.png" => ["Unsure", 0.5],
      "https://www.piyaoba.org/wp-content/uploads/2021/11/RLight.png" => ["False", 0.0],
    }
  end

  def get_claim_review_results_from_raw_claim_review(raw_claim_review)
    image_url = raw_claim_review["page"].search("div.post section#gray-color-box img.attachment-medium")[0].attributes["src"].value rescue nil
    return image_url_result_map[image_url] if image_url
  end

  def claim_review_reviewed_from_raw_claim_review(raw_claim_review)
    raw_claim_review["page"].search("div.post section#gray-color-box div.elementor-widget-text-editor div.elementor-widget-container").first.text.split("\t").reject(&:empty?).last
  end

  def claim_review_body_from_raw_claim_review(raw_claim_review)
    raw_claim_review['page'].search("div.elementor-widget-container p").collect(&:text).collect(&:strip).join(" ")
  end

  def parse_raw_claim_review(raw_claim_review)
    ld_json_obj = extract_ld_json_script_block(raw_claim_review["page"], 0)
    person = ld_json_obj["@graph"].select{|x| x["@type"] == "Person"}.first || {}
    claim_review_result, claim_review_result_score = get_claim_review_results_from_raw_claim_review(raw_claim_review)
    {
      id: raw_claim_review['url'],
      created_at: og_date_from_raw_claim_review(raw_claim_review),
      author: person["name"],
      author_link: person["url"],
      claim_review_headline: og_title_from_raw_claim_review(raw_claim_review).split(" - ").first,
      claim_review_body: claim_review_body_from_raw_claim_review(raw_claim_review),
      claim_review_image_url: claim_review_image_url_from_raw_claim_review(raw_claim_review),
      claim_review_reviewed: claim_review_reviewed_from_raw_claim_review(raw_claim_review),
      claim_review_result: claim_review_result,
      claim_review_result_score: claim_review_result_score,
      claim_review_url: raw_claim_review['url'],
      raw_claim_review: ld_json_obj
    }
  end
end

#
#
#
# curl 'https://www.piyaoba.org/wp-admin/admin-ajax.php' \
#   -H 'authority: www.piyaoba.org' \
#   -H 'accept: application/json, text/javascript, */*; q=0.01' \
#   -H 'accept-language: en-US,en;q=0.9' \
#   -H 'content-type: application/x-www-form-urlencoded; charset=UTF-8' \
#   -H 'cookie: _gid=GA1.2.935394367.1653572223; __atuvc=3%7C21; __atuvs=628f82742fe12e40002; _gat_gtag_UA_220088293_1=1; _ga_8NEWPNJPJT=GS1.1.1653572220.1.1.1653573968.0; _ga=GA1.1.904487267.1653572223' \
#   -H 'dnt: 1' \
#   -H 'origin: https://www.piyaoba.org' \
#   -H 'referer: https://www.piyaoba.org/all-disinformation-alert/' \
#   -H 'sec-ch-ua: " Not A;Brand";v="99", "Chromium";v="101", "Google Chrome";v="101"' \
#   -H 'sec-ch-ua-mobile: ?0' \
#   -H 'sec-ch-ua-platform: "macOS"' \
#   -H 'sec-fetch-dest: empty' \
#   -H 'sec-fetch-mode: cors' \
#   -H 'sec-fetch-site: same-origin' \
#   -H 'user-agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/101.0.4951.64 Safari/537.36' \
#   -H 'x-requested-with: XMLHttpRequest' \
#   --data-raw '' \
#   --compressed