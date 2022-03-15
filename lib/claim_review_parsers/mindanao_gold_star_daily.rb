
# frozen_string_literal: true

# Parser for https://mindanaogoldstardaily.com/category/factsfirstph-2/
class MindanaoGoldStarDaily < ClaimReviewParser
  include PaginatedReviewClaims

  def hostname
    'https://mindanaogoldstardaily.com'
  end

  def fact_list_path(page = 1)
    "/category/factsfirstph-2/page/#{page}/"
  end


  def url_extraction_search
    'div.tdc-content-wrap div.td-module-meta-info p.entry-title a'
  end

  def url_extractor(atag)
    atag.attributes['href'].value
  end

  def created_at_from_article_or_raw_claim_review(article, raw_claim_review)
    Time.parse(article["datePublished"]) rescue og_date_from_raw_claim_review(raw_claim_review)
  end

  def claim_review_headline_from_article_or_raw_claim_review(article, raw_claim_review)
    article && article["headline"] || raw_claim_review["page"].search("h1.entry-title").text
  end

  def claim_review_image_url_from_article_or_raw_claim_review(article, raw_claim_review)
    article && article["image"] && article["image"]["@id"] || value_from_og_tag(search_for_og_tags(raw_claim_review["page"], ["og:image"]))
  end

  def parse_raw_claim_review(raw_claim_review)
    article = extract_ld_json_script_block(raw_claim_review["page"], 0)["@graph"].select{|x| x["@type"] == "Article"}.first
    {
      id: raw_claim_review['url'],
      created_at: created_at_from_article_or_raw_claim_review(article, raw_claim_review),
      author: raw_claim_review["page"].search("div.td-post-author-name a").text,
      author_link: (raw_claim_review["page"].search("div.td-post-author-name a")[0].attributes["href"].value rescue nil),
      claim_review_headline: claim_review_headline_from_article_or_raw_claim_review(article, raw_claim_review),
      claim_review_body: raw_claim_review["page"].search("div.td-ss-main-content div.td-post-content p").collect(&:text).join(" "),
      claim_review_image_url: claim_review_image_url_from_article_or_raw_claim_review(article, raw_claim_review),
      claim_review_url: raw_claim_review['url']
    }
  end
end
