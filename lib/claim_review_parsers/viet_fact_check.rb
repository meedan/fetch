# frozen_string_literal: true

# Parser for https://vietfactcheck.org
class VietFactCheck < ClaimReviewParser
  include PaginatedReviewClaims
  def hostname
    'https://vietfactcheck.org'
  end

  def request_fact_page(page)
    post_url(
      self.hostname+"/?infinity=scrolling",
      "action=infinite_scroll&page=#{page}&currentday=30.01.22&order=DESC&scripts[0]=jquery&scripts[1]=tiled-gallery&scripts[2]=jquery-core&scripts[3]=jquery-migrate&scripts[4]=tortuga-jquery-navigation&scripts[5]=flexslider&scripts[6]=tortuga-post-slider&scripts[7]=regenerator-runtime&scripts[8]=wp-polyfill&scripts[9]=wp-hooks&scripts[10]=wp-i18n&scripts[11]=media-video-jwt-bridge&scripts[12]=google_gtagjs&scripts[13]=the-neverending-homepage&scripts[14]=jetpack-photon&scripts[15]=coblocks-animation&scripts[16]=coblocks-lightbox&scripts[17]=coblocks-gist&scripts[18]=jetpack-carousel&scripts[19]=jetpack-search-widget&scripts[20]=jetpack-facebook-embed&scripts[21]=jetpack-twitter-timeline&scripts[22]=jetpack-lazy-images-polyfill-intersectionobserver&scripts[23]=jetpack-lazy-images&scripts[24]=wp-dom-ready&scripts[25]=jetpack-block-tiled-gallery&styles[0]=the-neverending-homepage&styles[1]=wp-block-library&styles[2]=jetpack-layout-grid&styles[3]=mediaelement&styles[4]=wp-mediaelement&styles[5]=coblocks-frontend&styles[6]=wpcom-text-widget-styles&styles[7]=wp-components&styles[8]=godaddy-styles&styles[9]=jetpack-carousel-swiper-css&styles[10]=jetpack-carousel&styles[11]=tiled-gallery&styles[12]=jetpack_likes&styles[13]=tortuga-stylesheet&styles[14]=genericons&styles[15]=tortuga-flexslider&styles[16]=jetpack-social-menu&styles[17]=jetpack-search-widget&styles[18]=wpcom_instagram_widget&styles[19]=jetpack_facebook_likebox&styles[20]=jetpack_css&styles[21]=global-styles&styles[22]=dashicons&styles[23]=tortuga-default-fonts&styles[24]=jetpack-global-styles-frontend-style&styles[25]=jetpack-block-tiled-gallery&query_args[error]=&query_args[m]=&query_args[p]=0&query_args[post_parent]=&query_args[subpost]=&query_args[subpost_id]=&query_args[attachment]=&query_args[attachment_id]=0&query_args[name]=&query_args[pagename]=&query_args[page_id]=0&query_args[second]=&query_args[minute]=&query_args[hour]=&query_args[day]=0&query_args[monthnum]=0&query_args[year]=0&query_args[w]=0&query_args[category_name]=&query_args[tag]=&query_args[cat]=&query_args[tag_id]=&query_args[author]=&query_args[author_name]=&query_args[feed]=&query_args[tb]=&query_args[paged]=0&query_args[meta_key]=&query_args[meta_value]=&query_args[preview]=&query_args[s]=&query_args[sentence]=&query_args[title]=&query_args[fields]=&query_args[menu_order]=&query_args[embed]=&query_args[category__in][]=&query_args[category__not_in][]=&query_args[category__and][]=&query_args[post__in][]=&query_args[post__not_in][]=&query_args[post_name__in][]=&query_args[tag__in][]=&query_args[tag__not_in][]=&query_args[tag__and][]=&query_args[tag_slug__in][]=&query_args[tag_slug__and][]=&query_args[post_parent__in][]=&query_args[post_parent__not_in][]=&query_args[author__in][]=&query_args[author__not_in][]=&query_args[posts_per_page]=6&query_args[ignore_sticky_posts]=false&query_args[suppress_filters]=false&query_args[cache_results]=false&query_args[update_post_term_cache]=true&query_args[lazy_load_term_meta]=true&query_args[update_post_meta_cache]=true&query_args[post_type]=&query_args[nopaging]=false&query_args[comments_per_page]=50&query_args[no_found_rows]=false&query_args[order]=DESC&query_before=2022-05-27%2006%3A39%3A42&last_post_date=2022-04-08%2012%3A23%3A50"
    )
  end

  def parsed_fact_list_page(page)
    Nokogiri.parse(
    "<html><body>"+JSON.parse(
        request_fact_page(page)
      )["html"].to_s+"</body></html>"
    )
  end

  def url_extraction_search
    'article a[rel="bookmark"]'
  end

  def url_extractor(atag)
    atag.attributes['href'].value
  end
  
  def claim_review_result_from_raw_claim_review(raw_claim_review)
    image_url = raw_claim_review["page"].search("article div.alignwide figure.wp-block-media-text__media img").select{|x| x.attributes["data-image-title"].value.to_s.include?("dial")}.first.attributes["src"].value rescue nil
    mapped_image_classes = {
      "dial-false" => ["False", 0.0],
      "dial-mostly_false" => ["Mostly False", 0.0],
      "dial-half-true" => ["Half True", 0.0],
      "dial-mostly_true" => ["Mostly True", 0.0],
      "dial-true" => ["True", 0.0],
      "dial_sai" => ["False", 0.0],
      "dial-phan-lon-sai" => ["Mostly False", 0.0],
      "dial-nua-sai" => ["Half True", 0.0],
      "dial-phan-lon-that" => ["Mostly True", 0.0],
      "dial_that" => ["True", 0.0],
    }
    mapped_image_classes.each do |image_url_subsection, classification|
      if image_url.include?(image_url_subsection)
        return classification
      end
    end
  end

  def get_claim_review_body_from_raw_claim_review(raw_claim_review)
    split_node = raw_claim_review["page"].search("article div.entry-content hr").first
    children = []
    after_split = false
    raw_claim_review["page"].search("article div.entry-content").children.each do |child|
      if split_node == child
        after_split = true
      end
      children << child if after_split
    end
    children.collect(&:text).join(" ").strip
  end

  def parse_raw_claim_review(raw_claim_review)
    claim_review_reviewed = raw_claim_review["page"].search("article div.entry-content p").select{|x| x.text[0..5] == "Claim:"}.first.text.gsub("Claim: ", "") rescue nil
    claim_review_result, claim_review_result_score = claim_review_result_from_raw_claim_review(raw_claim_review)
    {
      id: raw_claim_review['url'],
      created_at: Time.parse(og_date_from_raw_claim_review(raw_claim_review)),
      claim_review_headline: og_title_from_raw_claim_review(raw_claim_review),
      claim_review_body: get_claim_review_body_from_raw_claim_review(raw_claim_review),
      claim_review_image_url: claim_review_image_url_from_raw_claim_review(raw_claim_review),
      claim_review_reviewed: claim_review_reviewed,
      claim_review_result: claim_review_result,
      claim_review_result_score: claim_review_result_score,
      claim_review_url: raw_claim_review['url'],
    }
  end
end