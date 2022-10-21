
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
    Time.parse(article["datePublished"]) rescue Time.parse(og_date_from_raw_claim_review(raw_claim_review)) rescue nil
  end

  def claim_review_headline_from_article_or_raw_claim_review(article, raw_claim_review)
    article && article["headline"] || raw_claim_review["page"].search("div.s-post-header h1").text
  end

  def claim_review_image_url_from_article_or_raw_claim_review(article, raw_claim_review)
    article && article["image"] && article["image"]["@id"] || get_og_image_url(raw_claim_review)
  end

  def parse_raw_claim_review(raw_claim_review)
    article = extract_ld_json_script_block(raw_claim_review["page"], 0)["@graph"].select{|x| x["@type"] == "Article"}.first
    {
      id: raw_claim_review['url'],
      created_at: created_at_from_article_or_raw_claim_review(article, raw_claim_review),
      author: raw_claim_review["page"].search("div.post-author a").text,
      author_link: (raw_claim_review["page"].search("div.post-author a")[0].attributes["href"].value rescue nil),
      claim_review_headline: claim_review_headline_from_article_or_raw_claim_review(article, raw_claim_review),
      claim_review_body: raw_claim_review["page"].search("div.article-wrap div.article-content p").collect(&:text).join(" "),
      claim_review_image_url: claim_review_image_url_from_article_or_raw_claim_review(article, raw_claim_review),
      claim_review_url: raw_claim_review['url']
    }
  end
end
