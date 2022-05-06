# frozen_string_literal: true

# Parser for http://hindi.boomlive.in/ - does not follow standard Pagination scheme from PaginatedReviewClaims!
class HindiBoomLive < ClaimReviewParser
  include PaginatedReviewClaims
  def hostname
    'http://hindi.boomlive.in'
  end

  def fact_list_path(page = 1)
    # appears to be zero-indexed
    "/fast-check/#{page}"
  end

  def url_extraction_search
    'main#main div.category-articles-list h2.entry-title a'
  end

  def url_extractor(atag)
    hostname + atag.attributes['href'].value
  end

  def get_article_author(article)
    if article && article["author"] && article["author"].class == Array
      {
        author: article && article["author"][0] && article["author"][0]["name"],
        author_link: article && article["author"][0] && hostname+article["author"][0]["url"],      
      }
    else
      {
        author: article && article["author"] && article["author"]["name"],
        author_link: article && article["author"] && hostname+article["author"]["url"],      
      }
    end
  end

  def parse_raw_claim_review(raw_claim_review)
    article = extract_ld_json_script_block(raw_claim_review["page"], 0)
    article && article["author"] && article["author"]["name"] rescue binding.pry
    {
      id: raw_claim_review["url"],
      created_at: Time.parse(article['datePublished']||og_date_from_raw_claim_review(raw_claim_review)),
      claim_review_headline: article["claimReviewed"],
      claim_review_body: raw_claim_review["page"].search("div.single-post-summary h2").text,
      claim_review_reviewed: article["itemReviewed"] && article["itemReviewed"]["name"],
      claim_review_image_url: article["image"] && article["image"]["contentUrl"],
      claim_review_result: article["reviewRating"] && article["reviewRating"]["alternateName"],
      claim_review_result_score: claim_result_score_from_raw_claim_review(article["reviewRating"]),
      claim_review_url: raw_claim_review['url'],
      raw_claim_review: article
    }.merge(
      get_article_author(article)
    )
  end
end
