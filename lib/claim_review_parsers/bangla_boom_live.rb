# frozen_string_literal: true

# Parser for http://bangla.boomlive.in/ - does not follow standard Pagination scheme from PaginatedReviewClaims!
class BanglaBoomLive < ClaimReviewParser
  include PaginatedReviewClaims
  def hostname
    'http://bangla.boomlive.in'
  end

  def fact_list_path(page = 1)
    # appears to be zero-indexed
    "/fact-check/#{page}"
  end

  def url_extraction_search
    'main#main div.category-articles-list h2.entry-title a'
  end

  def url_extractor(atag)
    hostname + atag.attributes['href'].value
  end

  def parse_raw_claim_review(raw_claim_review)
    article = extract_ld_json_script_block(raw_claim_review["page"], 0)
    author, author_link = get_author_and_link_from_article(article, self.hostname)
    {
      id: raw_claim_review["url"],
      created_at: Time.parse(article['datePublished']||og_date_from_raw_claim_review(raw_claim_review)),
      author: author,
      author_link: author_link,
      claim_review_headline: article["claimReviewed"],
      claim_review_body: raw_claim_review["page"].search("div.single-post-summary h2").text,
      claim_review_reviewed: article && article["itemReviewed"] && article["itemReviewed"]["name"],
      claim_review_image_url: article && article["image"] && article["image"]["contentUrl"],
      claim_review_result: article && article["reviewRating"] && article["reviewRating"]["alternateName"],
      claim_review_result_score: claim_result_score_from_raw_claim_review((article && article["reviewRating"] ||{})),
      claim_review_url: raw_claim_review['url'],
      raw_claim_review: article
    }
  end
end
