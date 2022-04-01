# frozen_string_literal: true

class Tsek < ClaimReviewParser
  include PaginatedReviewClaims
  def initialize(cursor_back_to_date = nil, overwrite_existing_claims=false, send_notifications = true)
    super(cursor_back_to_date, overwrite_existing_claims, send_notifications)
    @fact_list_page_parser = 'json'
    @already_observed_ids = []
    @raw_response = {}
  end

  def hostname
    'https://www.tsek.ph'
  end

  def request_fact_page
    RestClient::Request.execute(
      method: :get,
      url: self.hostname+"/wp-json/newspack-blocks/v1/articles?className=is-style-borders&imageShape=uncropped&moreButton=1&postsToShow=20&mediaPosition=left&mobileStack=1&showExcerpt=1&excerptLength=55&showReadMore=0&readMoreLabel=Keep%20reading&showDate=1&showImage=1&showCaption=0&disableImageLazyLoad=0&minHeight=0&moreButtonText&showAuthor=1&showAvatar=1&showCategory=0&postLayout=list&columns=3&&&&&&&typeScale=4&imageScale=3&sectionHeader&specificMode=0&textColor&customTextColor&singleMode=0&showSubtitle=0&postType%5B0%5D=post&textAlign=left&page=2&exclude_ids=#{@already_observed_ids.join(",")}",
    )
  end

  def get_page_urls
    JSON.parse(
      request_fact_page
    )["items"].collect do |article|
      parsed = Nokogiri.parse(article["html"])
      @already_observed_ids << parsed.children[0].attributes["data-post-id"].value
      @already_observed_ids.uniq!
      parsed.search("article.type-post h2 a").collect{|x| x.attributes["href"].value}.first
    end
  end

  def get_new_fact_page_urls(page)
    urls = get_page_urls
    urls-get_existing_urls(urls)
  end

  def get_image_url(raw_claim_review)
    search_for_og_tags(raw_claim_review["page"], ["og:image"]).attributes["content"].value rescue nil
  end

  def get_description(raw_claim_review)
    description = search_for_og_tags(raw_claim_review["page"], ["og:description"]).attributes["content"].value rescue nil
    description = raw_claim_review["page"].search("article.post div.entry-content p").collect(&:text).join(" ") if description.nil?
    description
  end

  def parse_raw_claim_review(raw_claim_review)
    news_article = extract_ld_json_script_block(raw_claim_review["page"], 0)["@graph"].select{|x| x["@type"] == "NewsArticle"}[0] rescue {}
    author = extract_ld_json_script_block(raw_claim_review["page"], 0)["@graph"].select{|x| x["@type"] == "Person"}.last rescue {}
    {
      id: raw_claim_review['url'],
      created_at: get_created_at_from_article(news_article),
      author: author["name"],
      author_link: author["url"],
      claim_review_headline: news_article["headline"],
      claim_review_body: get_description(raw_claim_review),
      claim_review_image_url: get_image_url(raw_claim_review),
      claim_review_result: news_article["articleSection"] && news_article["articleSection"][0],
      claim_review_url: raw_claim_review['url'],
      raw_claim_review: news_article
    }
  end
end