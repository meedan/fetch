class TempoCekfakta < ClaimReviewParser
  include PaginatedReviewClaims
  def initialize(cursor_back_to_date = nil, overwrite_existing_claims=false, send_notifications = true)
    super(cursor_back_to_date, overwrite_existing_claims, send_notifications)
    @user_agent = "Meedan Data Crawler"
  end

  def hostname
    'https://cekfakta.tempo.co'
  end

  def fact_list_path(date)
    "/#{date.year}/#{date.strftime("%m")}"
  end

  def request_fact_page(date)
    request(:get, self.hostname+self.fact_list_path(date))
  end

  def parsed_fact_list_page(date)
    Nokogiri.parse(
      request_fact_page(date)
    )
  end
  

  def get_claim_reviews(time=DateTime.now)
    raw_claims = store_claim_reviews_for_page(time)
    until finished_iterating?(raw_claims)
      time = time.prev_month
      raw_claims = store_claim_reviews_for_page(time)
    end
  end

  def url_extraction_search
    "figure.img-card a"
  end

  def domain_is_only_cekfakta(url)
    url.include?("cekfakta.tempo.co")
  end

  def url_extractor(atag)
    url = atag.attributes["href"].value
    url = domain_is_only_cekfakta(url) ? url : nil
    url = "http:"+url if url.to_s[0..1] == "//"
    url
  end

  def store_claim_reviews_for_page(time=DateTime.now)
    process_claim_reviews(
      get_parsed_fact_pages_from_urls(
        get_new_fact_page_urls(
          time
        ).uniq
      )
    )
  end

  def image_url_result_map
    {
      "https://www.tempo.co/images/cekfakta/keliru_teks.png" => ["False", 0.0],
      "https://www.tempo.co/images/cekfakta/sesat_teks.png" => ["Misleading", 0.25],
      "https://www.tempo.co/images/cekfakta/tidak_terbukti_teks.png" => ["Not Proven", 0.5],
      "https://www.tempo.co/images/cekfakta/sebagian_benar_teks.png" => ["Partially True", 0.75],
      "https://www.tempo.co/images/cekfakta/benar_teks.png" => ["True", 1.0],
    }
  end

  def get_date_from_raw_claim_review(raw_claim_review)
    Time.parse(raw_claim_review["page"].search("h4.date").first.text) rescue nil
  end

  def get_claim_review_results_from_raw_claim_review(raw_claim_review)
    image_url = raw_claim_review['page'].search("main.main-left div.detail-in img")[0].attributes["src"].value rescue nil
    return image_url_result_map[image_url] if image_url
  end

  def get_image_from_raw_claim_review(raw_claim_review)
    get_og_image_url(raw_claim_review) || raw_claim_review['page'].search("main.main-left div.detail-in img")[1].attributes["src"].value rescue nil
  end

  def get_created_at_from_raw_claim_review(raw_claim_review)
    get_date_from_raw_claim_review(raw_claim_review)||Time.parse(og_date_from_raw_claim_review(raw_claim_review)) rescue nil
  end

  def parse_raw_claim_review(raw_claim_review)
    return {} if !domain_is_only_cekfakta(raw_claim_review['url'])
    claim_review_result, claim_review_result_score = get_claim_review_results_from_raw_claim_review(raw_claim_review)
    {
      id: raw_claim_review['url'],
      created_at: get_created_at_from_raw_claim_review(raw_claim_review),
      author: "Tempo",
      author_link: "https://cekfakta.tempo.co",
      claim_review_headline: raw_claim_review["page"].search("h1.title").text,
      claim_review_body: raw_claim_review['page'].search("main.main-left div.detail-in p").text,
      claim_review_reviewed: raw_claim_review["page"].search("h1.title").text,
      claim_review_image_url: get_image_from_raw_claim_review(raw_claim_review),
      claim_review_result: claim_review_result,
      claim_review_result_score: claim_review_result_score,
      claim_review_url: raw_claim_review['url'],
      raw_claim_review: nil
    }
  end
end