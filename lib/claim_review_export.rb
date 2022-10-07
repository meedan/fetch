module ClaimReviewExport
  def convert_to_claim_review(claim_review, include_raw=true)
    output = {
      "identifier": claim_review["id"],
      "@context": 'http://schema.org',
      "@type": 'ClaimReview',
      "datePublished": Time.parse(claim_review['created_at']).strftime('%Y-%m-%d'),
      "url": claim_review['claim_review_url'],
      "author": {
        "name": claim_review['author'],
        "url": claim_review['author_link']
      },
      "inLanguage": claim_review['language'],
      "headline": claim_review['claim_review_headline'],
      "claimReviewed": claim_review['claim_review_reviewed'],
      "text": claim_review['claim_review_body'],
      "image": claim_review['claim_review_image_url'],
      "keywords": claim_review['keywords'],
      "reviewRating": {
        "@type": 'Rating',
        "ratingValue": claim_review['claim_review_result_score'],
        "bestRating": 1,
        "alternateName": claim_review['claim_review_result']
      },
    }
    output[:raw] = claim_review if include_raw
    output
  end
end