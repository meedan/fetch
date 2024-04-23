# frozen_string_literal: true

# Parser for https://www.animalpolitico.com/sabueso/?seccion=discurso
class AnimalPolitico < ClaimReviewParser
  include PaginatedReviewClaims
  def self.deprecated
    true
  end

  def initialize(cursor_back_to_date = nil, overwrite_existing_claims=false, send_notifications = true)
    super(cursor_back_to_date, overwrite_existing_claims, send_notifications)
    @fact_list_page_parser = 'json'
  end

  def hostname
    "https://admin.animalpolitico.com"
  end

  def front_page_path
    "/index.php/wp-json/wp/v2/elsabueso"
  end

  def front_page_urls(page)
    [
      [hostname+front_page_path+"?calificacion=&per_page=50&page=#{page}", "fact-checking"],
      [hostname+front_page_path+"?categoria=desinformacion&per_page=50&page=#{page}", "desinformacion"],
      [hostname+front_page_path+"?categoria=teexplico&per_page=50&page=#{page}", "te-explico"]
    ]
  end

  def get_new_fact_page_urls(page)
    all_articles = get_all_articles(page)
    existing_urls = get_existing_urls(all_articles.collect{|x| x["url"]})
    process_claim_reviews(get_parsed_fact_pages_from_urls(all_articles.reject{|x| existing_urls.include?(x["url"])}))
  end

  def get_front_page(url)
    JSON.parse(get_url(url))
  end

  def get_articles(url, tag)
    get_front_page(url).collect{|x| x["url"] = "https://www.animalpolitico.com/verificacion-de-hechos/#{tag}/#{x["slug"]}" ; x}.uniq
  end

  def get_all_articles(page)
    front_page_urls(page).collect{|u, t| get_articles(u, t)}.flatten.compact.uniq
  end
  
  def parsed_fact_page(fact_page_response)
    [fact_page_response["url"], parse_raw_claim_review(QuietHashie[{ raw_response: fact_page_response, url: fact_page_response["url"] }])]
  end

  def claim_review_body_from_raw_claim_review(raw_claim_review)
    raw_claim_review["raw_response"] && raw_claim_review["raw_response"]["acf"] && Nokogiri.parse("<html>" + (raw_claim_review["raw_response"]["acf"]["extracto"] || raw_claim_review["raw_response"]["acf"]["contenido"]).to_s + "</html>").text || ""
  end

  def get_image_url(raw_claim_review)
    raw_claim_review["raw_response"]["yoast_head_json"]["og_image"][0]["url"] rescue nil
  end

  def parse_raw_claim_review(raw_claim_review)
    {
      id: raw_claim_review["url"],
      created_at: raw_claim_review["raw_response"] && raw_claim_review["raw_response"]["yoast_head_json"] && (Time.parse(raw_claim_review["raw_response"]["yoast_head_json"]["article_modified_time"]) rescue nil),
      author: raw_claim_review["raw_response"]["author_name"],
      claim_review_headline: raw_claim_review["raw_response"]["title"] && raw_claim_review["raw_response"]["title"]["rendered"],
      claim_review_body: claim_review_body_from_raw_claim_review(raw_claim_review),
      claim_review_reviewed: raw_claim_review["raw_response"]["acf"] && raw_claim_review["raw_response"]["acf"]["ficha_tecnica_fact_checking"] && raw_claim_review["raw_response"]["acf"]["ficha_tecnica_fact_checking"]["frase"],
      claim_review_image_url: get_image_url(raw_claim_review),
      claim_review_result: raw_claim_review["raw_response"]["meta"] && raw_claim_review["raw_response"]["meta"]["ap_sabueso_calification"],
      claim_review_url: raw_claim_review["url"],
      raw_claim_review: raw_claim_review["raw_response"]
    }
  end
end
