# frozen_string_literal: true

# Parser for https://newschecker.in
class ClimateFactCheck < ClaimReviewParser
  include PaginatedReviewClaims
  def hostnames
    [
      "https://climatefactchecks.org",
      "https://climatefactchecks.org/sinhala",
      "https://climatefactchecks.org/hindi",
      "https://climatefactchecks.org/assamese",
      "https://climatefactchecks.org/gujarati",
      "https://climatefactchecks.org/marathi",
      "https://climatefactchecks.org/malayalam",
      "https://climatefactchecks.org/tamil",
      "https://climatefactchecks.org/odia",
      "https://climatefactchecks.org/bangla",
    ]
  end

  def fact_list_path(page = 1)
    "/page/#{page}/"
  end

  def url_extraction_search
    'article .entry-title a'
  end

  def url_extractor(atag)
    atag.attributes['href'].value
  end

  def get_fact_page_urls(page)
    hostnames.collect{|hostname|
      extract_urls_from_html(
        nokogiri_parse(
          get_url(
            hostname + fact_list_path(page)
          )
        )
      )
    }.flatten.uniq
  end

  def get_subheads(raw_claim_review)
    raw_claim_review["page"].search("article div.entry-content p strong")
  end
  def get_claim_review_reviewed(raw_claim_review)
    get_subheads(raw_claim_review).select{|x| x.text == "CLAIM"}.first.parent.next_sibling.next_sibling.text
  end

  def get_claim_review_result(raw_claim_review)
    result = get_subheads(raw_claim_review).select{|x| x.text == "FACT"}.first.parent.next_sibling.next_sibling.text
    result.split(".").first.strip
  end

  def get_article_safely(raw_claim_review)
    claim_review = extract_ld_json_script_block(raw_claim_review["page"], 0)
    claim_review && claim_review["@graph"] && claim_review["@graph"].select{|x| x["@type"] == "Article"}.first || {}
  end

  def is_parseable(raw_claim_review)
    ["CLAIM", "FACT"].each do |clause|
      return false if get_subheads(raw_claim_review).select{|x| x.text == clause}.first.nil?
    end
    return true
  end
  def parse_raw_claim_review(raw_claim_review)
    return {} if !is_parseable(raw_claim_review)
    article = get_article_safely(raw_claim_review)
    {
      id: raw_claim_review['url'],
      created_at: (Time.parse(article["datePublished"]) rescue nil),
      author: article && article["author"] && article["author"]["name"],
      author_link: article && article["author"] && article["author"]["@id"],
      claim_review_headline: raw_claim_review["page"].search("title").text,
      claim_review_body: raw_claim_review["page"].search("article div.entry-content p").collect(&:text)[0..3].join(" "),
      claim_review_image_url: get_og_image_url(raw_claim_review),
      claim_review_reviewed: get_claim_review_reviewed(raw_claim_review),
      claim_review_result: get_claim_review_result(raw_claim_review),
      claim_review_url: raw_claim_review['url'],
      raw_claim_review: article
    }
  end
end
