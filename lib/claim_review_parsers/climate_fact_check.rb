# frozen_string_literal: true


# Parser for https://climatefactchecks.org
class ClimateFactCheck < ClaimReviewParser
  include PaginatedReviewClaims
  def self.deprecated
    true
  end

  def hostnames
    [
      "https://climatefactchecks.org/category/fact-check/",
      "https://climatefactchecks.org/sinhala/category/fact-check",
      "https://climatefactchecks.org/hindi/category/fact-check/",
      "https://climatefactchecks.org/assamese/category/fact-check/",
      "https://climatefactchecks.org/gujarati/category/fact-check/",
      "https://climatefactchecks.org/marathi/category/fact-check/",
      "https://climatefactchecks.org/malayalam/category/fact-check/",
      "https://climatefactchecks.org/tamil/category/fact-check/",
      "https://climatefactchecks.org/odia/category/fact-check/",
      "https://climatefactchecks.org/bangla/category/fact-check/",
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
          ) || "<html></html>"
        )
      )
    }.flatten.uniq
  end

  def get_subheads(raw_claim_review)
    raw_claim_review["page"].search("article div.entry-content p strong")
  end

  def claim_and_fact_clauses
    [
      ["दावा", "तथ्य"],
      ["দাবী", "তথ্য"],
      ["દાવો", "હકીકત"],
      ["दावा", "वस्तुस्थिती"],
      ["അവകാശവാദം", "വസ്തുത"],
      ["ଦାବି", "ସତ୍ୟ"],
      ["CLAIM", "FACT"]
    ]
  end

  def get_claim_review_reviewed(raw_claim_review)
    get_subheads(raw_claim_review).select{|x| claim_and_fact_clauses.collect(&:first).include?(x.text)}.first.parent.next_sibling.next_sibling.text rescue nil
  end

  def get_claim_review_result(raw_claim_review)
    result = get_subheads(raw_claim_review).select{|x| claim_and_fact_clauses.collect(&:last).include?(x.text)}.first.parent.next_sibling.next_sibling.text rescue nil
    result.split(".").first.strip rescue nil
  end

  def get_article_safely(raw_claim_review)
    claim_review = extract_ld_json_script_block(raw_claim_review["page"], 0)
    claim_review && claim_review["@graph"] && claim_review["@graph"].select{|x| x["@type"] == "Article"}.first || {}
  end

  def is_parseable(raw_claim_review)
    !get_claim_review_reviewed(raw_claim_review).nil? && !get_claim_review_result(raw_claim_review).nil?
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
