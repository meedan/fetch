# frozen_string_literal: true

# Parser for https://mafindo.github.io/docs/v2/#the-news-object
# curl --request POST \
#   --url https://yudistira.turnbackhoax.id/api/antihoax/ \
#   --header 'Content-Type: application/x-www-form-urlencoded' \
#   --header 'Accept: application/json' \
#   --data 'key=123456&id=891&limit=1&offset=1'
class TempoCekfakta < ClaimReviewParser
  def hostname
    'https://cekfakta.tempo.co'
  end

  def fact_list_path(date)
    "/#{date.year}/#{date.strftime("%m")}"
  end

  def request_fact_page(date)
    RestClient.get(self.hostname+self.fact_list_path(date))
  end

  def get_fact_page_response(date)
    Nokogiri.parse(
      request_fact_page(date)
    )
  end

  def get_claim_reviews
    time = DateTime.now
    raw_claims = store_new_claim_reviews_for_page(time)
    until finished_iterating?(raw_claims)
      time = time.prev_month
      raw_claims = store_new_claim_reviews_for_page(time)
    end
  end

  def extract_urls(response)
    response.search("section#article div.card a").collect{|a| a.attributes["href"].value}.uniq
  end

  def store_new_claim_reviews_for_page(time=Time.now)
    response = get_fact_page_response(time)
    existing_urls = get_existing_urls(extract_urls(response))
    process_claim_reviews(
      parse_raw_claim_reviews(
        response.reject{|d| existing_urls.include?(url_from_id(d["id"]))}
      )
    )
  end
  
  def parse_raw_claim_review(raw_claim_review)
    # binding.pry
    article = extract_ld_json_script_block(raw_claim_review["page"], 0)
    authors = @authors.select{|x| !([x["id"]]&[raw_claim_review['authors']].flatten).empty?}
    {
      id: raw_claim_review['id'],
      created_at: Time.parse(raw_claim_review['tanggal']),
      author: authors_from_authors(authors),
      author_link: author_link_from_authors(authors),
      claim_review_headline: raw_claim_review['title'],
      claim_review_body: raw_claim_review['fact'],
      claim_review_reviewed: raw_claim_review['source_link'],
      claim_review_image_url: raw_claim_review['picture1'],
      claim_review_result: raw_claim_review['classification'],
      claim_review_result_score: rating_map[raw_claim_review['classification']],
      claim_review_url: url_from_id(raw_claim_review['id']),
      raw_claim_review: raw_claim_review
    }
  end
end
# Mafindo.new.get_claim_reviews