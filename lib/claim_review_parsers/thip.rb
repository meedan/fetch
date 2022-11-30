# frozen_string_literal: true

# Parser for https://www.desifacts.org/
class Thip < ClaimReviewParser
  include PaginatedReviewClaims
  def hostname
    "https://www.thip.media"
  end

  def index_paths
    self.index_path_map.keys
  end

  def get_language(index_path)
    self.index_path_map[index_path]
  end

  def index_path_map
    {
      "/category/health-news-fact-check/" => "en",
      "/category/hindi-health-fact-check/" => "hi",
      "/bengali-health-fact-check/" => "bn",
      "/health-fake-news-fact-check-punjabi/" => "pa",
      "/gujarati-fact-check/" => "gu",
      "/health-newsfact-check-nepali/" => "ne",
    }
  end

  def request_fact_page(index_path, page)
    @cookies = {"pll_language"=>get_language(index_path)}
    post_url(
      self.hostname+"/wp-admin/admin-ajax.php",
      URI.encode_www_form(fact_page_params(page)),
    )
  end

  def fact_page_params(page)
    {
      "action" => "td_ajax_block",
      "td_block_id" => "tdi_78",
      "td_column_number" => "2",
      "td_current_page" => page.to_s,
      "block_type" => "tdb_loop",
      "td_filter_value" => "",
      "td_user_action" => "",
      "td_magic_token" => "317372747e",
      "td_atts" => "{\"modules_on_row\":\"eyJhbGwiOiIzMy4zMzMzMzMzMyUiLCJwaG9uZSI6IjEwMCUifQ==\",\"modules_gap\":\"eyJsYW5kc2NhcGUiOiIxMCIsInBvcnRyYWl0IjoiMTAiLCJhbGwiOiIyMCJ9\",\"modules_category\":\"above\",\"show_excerpt\":\"none\",\"show_btn\":\"none\",\"ajax_pagination\":\"infinite\",\"hide_audio\":\"yes\",\"limit\":\"9\",\"all_modules_space\":\"eyJhbGwiOiIzMCIsImxhbmRzY2FwZSI6IjI1IiwicG9ydHJhaXQiOiIyMCIsInBob25lIjoiMjAifQ==\",\"art_title\":\"eyJhbGwiOiIxMnB4IDAgMCAwIiwibGFuZHNjYXBlIjoiMTJweCAwIDAgMCIsInBvcnRyYWl0IjoiMTBweCAwIDAgMCJ9\",\"f_title_font_family\":\"702\",\"f_title_font_size\":\"eyJhbGwiOiIxNiIsInBob25lIjoiMjAiLCJsYW5kc2NhcGUiOiIxNyIsInBvcnRyYWl0IjoiMTQifQ==\",\"f_title_font_line_height\":\"1.4\",\"f_title_font_weight\":\"600\",\"title_txt\":\"#000000\",\"title_txt_hover\":\"#000000\",\"all_underline_color\":\"#31d6aa\",\"all_underline_height\":\"eyJhbGwiOiIyIiwicG9ydHJhaXQiOiIyIiwicGhvbmUiOiIzIn0=\",\"show_com\":\"none\",\"show_date\":\"\",\"show_author\":\"none\",\"art_excerpt\":\"0\",\"image_height\":\"eyJhbGwiOiI2MCIsInBvcnRyYWl0IjoiNzAiLCJwaG9uZSI6IjUwIn0=\",\"image_radius\":\"5\",\"modules_category_margin\":\"0\",\"modules_category_padding\":\"eyJhbGwiOiI2cHggMTBweCIsInBvcnRyYWl0IjoiNHB4IDZweCIsImxhbmRzY2FwZSI6IjVweCA4cHgifQ==\",\"f_cat_font_family\":\"702\",\"f_cat_font_size\":\"eyJhbGwiOiIxMCIsInBvcnRyYWl0IjoiMTAifQ==\",\"f_cat_font_line_height\":\"1\",\"f_cat_font_weight\":\"400\",\"f_cat_font_transform\":\"uppercase\",\"cat_bg\":\"#60034c\",\"cat_bg_hover\":\"#60034c\",\"cat_txt\":\"#ffffff\",\"cat_txt_hover\":\"#ffffff\",\"f_meta_font_family\":\"702\",\"f_meta_font_size\":\"eyJwaG9uZSI6IjEyIn0=\",\"f_meta_font_weight\":\"\",\"f_meta_font_transform\":\"\",\"date_txt\":\"#555555\",\"f_ex_font_family\":\"\",\"f_ex_font_size\":\"eyJwaG9uZSI6IjE0In0=\",\"f_ex_font_weight\":\"\",\"ex_txt\":\"#555555\",\"meta_padding\":\"eyJhbGwiOiIyMHB4IDAgMCAxMHB4IiwicG9ydHJhaXQiOiIxNXB4IDAgMCAxMHB4In0=\",\"tdc_css\":\"eyJhbGwiOnsibWFyZ2luLWJvdHRvbSI6IjAiLCJkaXNwbGF5IjoiIn19\",\"pag_border_width\":\"0\",\"pag_text\":\"#000000\",\"pag_h_text\":\"#31d6aa\",\"pag_a_text\":\"#31d6aa\",\"pag_bg\":\"rgba(255,255,255,0)\",\"pag_h_bg\":\"rgba(255,255,255,0)\",\"pag_a_bg\":\"rgba(255,255,255,0)\",\"f_pag_font_family\":\"325\",\"f_pag_font_size\":\"12\",\"f_pag_font_transform\":\"uppercase\",\"f_pag_font_weight\":\"700\",\"mc1_tl\":\"100\",\"show_cat\":\"none\",\"category_id\":27,\"block_type\":\"tdb_loop\",\"separator\":\"\",\"custom_title\":\"\",\"custom_url\":\"\",\"block_template_id\":\"\",\"title_tag\":\"\",\"mc1_title_tag\":\"\",\"mc1_el\":\"\",\"offset\":\"\",\"post_ids\":\"-3968\",\"sort\":\"\",\"installed_post_types\":\"\",\"ajax_pagination_next_prev_swipe\":\"\",\"ajax_pagination_infinite_stop\":\"\",\"container_width\":\"\",\"m_padding\":\"\",\"m_radius\":\"\",\"modules_border_size\":\"\",\"modules_border_style\":\"\",\"modules_border_color\":\"#eaeaea\",\"modules_divider\":\"\",\"modules_divider_color\":\"#eaeaea\",\"h_effect\":\"\",\"image_size\":\"\",\"image_width\":\"\",\"image_floated\":\"no_float\",\"hide_image\":\"\",\"video_icon\":\"\",\"video_popup\":\"yes\",\"video_rec\":\"\",\"spot_header\":\"\",\"video_rec_title\":\"- Advertisement -\",\"video_rec_color\":\"\",\"video_rec_disable\":\"\",\"autoplay_vid\":\"yes\",\"show_vid_t\":\"block\",\"vid_t_margin\":\"\",\"vid_t_padding\":\"\",\"video_title_color\":\"\",\"video_title_color_h\":\"\",\"video_bg\":\"\",\"video_overlay\":\"\",\"vid_t_color\":\"\",\"vid_t_bg_color\":\"\",\"f_vid_title_font_header\":\"\",\"f_vid_title_font_title\":\"Video pop-up article title\",\"f_vid_title_font_settings\":\"\",\"f_vid_title_font_family\":\"\",\"f_vid_title_font_size\":\"\",\"f_vid_title_font_line_height\":\"\",\"f_vid_title_font_style\":\"\",\"f_vid_title_font_weight\":\"\",\"f_vid_title_font_transform\":\"\",\"f_vid_title_font_spacing\":\"\",\"f_vid_title_\":\"\",\"f_vid_time_font_title\":\"Video duration text\",\"f_vid_time_font_settings\":\"\",\"f_vid_time_font_family\":\"\",\"f_vid_time_font_size\":\"\",\"f_vid_time_font_line_height\":\"\",\"f_vid_time_font_style\":\"\",\"f_vid_time_font_weight\":\"\",\"f_vid_time_font_transform\":\"\",\"f_vid_time_font_spacing\":\"\",\"f_vid_time_\":\"\",\"meta_info_align\":\"\",\"meta_info_horiz\":\"content-horiz-left\",\"meta_width\":\"\",\"meta_margin\":\"\",\"meta_space\":\"\",\"meta_info_border_size\":\"\",\"meta_info_border_style\":\"\",\"meta_info_border_color\":\"#eaeaea\",\"meta_info_border_radius\":\"\",\"art_btn\":\"\",\"modules_cat_border\":\"\",\"modules_category_radius\":\"0\",\"modules_extra_cat\":\"\",\"author_photo\":\"\",\"author_photo_size\":\"\",\"author_photo_space\":\"\",\"author_photo_radius\":\"\",\"show_modified_date\":\"\",\"time_ago\":\"\",\"time_ago_add_txt\":\"ago\",\"time_ago_txt_pos\":\"\",\"show_review\":\"inline-block\",\"review_space\":\"\",\"review_size\":\"2.5\",\"review_distance\":\"\",\"excerpt_col\":\"1\",\"excerpt_gap\":\"\",\"excerpt_middle\":\"\",\"excerpt_inline\":\"\",\"show_audio\":\"block\",\"art_audio\":\"\",\"art_audio_size\":\"1.5\",\"btn_title\":\"\",\"btn_margin\":\"\",\"btn_padding\":\"\",\"btn_border_width\":\"\",\"btn_radius\":\"\",\"pag_space\":\"\",\"pag_padding\":\"\",\"pag_border_radius\":\"\",\"prev_tdicon\":\"\",\"next_tdicon\":\"\",\"pag_icons_size\":\"\",\"f_header_font_header\":\"\",\"f_header_font_title\":\"Block header\",\"f_header_font_settings\":\"\",\"f_header_font_family\":\"\",\"f_header_font_size\":\"\",\"f_header_font_line_height\":\"\",\"f_header_font_style\":\"\",\"f_header_font_weight\":\"\",\"f_header_font_transform\":\"\",\"f_header_font_spacing\":\"\",\"f_header_\":\"\",\"f_pag_font_title\":\"Pagination text\",\"f_pag_font_settings\":\"\",\"f_pag_font_line_height\":\"\",\"f_pag_font_style\":\"\",\"f_pag_font_spacing\":\"\",\"f_pag_\":\"\",\"f_title_font_header\":\"\",\"f_title_font_title\":\"Article title\",\"f_title_font_settings\":\"\",\"f_title_font_style\":\"\",\"f_title_font_transform\":\"\",\"f_title_font_spacing\":\"\",\"f_title_\":\"\",\"f_cat_font_title\":\"Article category tag\",\"f_cat_font_settings\":\"\",\"f_cat_font_style\":\"\",\"f_cat_font_spacing\":\"\",\"f_cat_\":\"\",\"f_meta_font_title\":\"Article meta info\",\"f_meta_font_settings\":\"\",\"f_meta_font_line_height\":\"\",\"f_meta_font_style\":\"\",\"f_meta_font_spacing\":\"\",\"f_meta_\":\"\",\"f_ex_font_title\":\"Article excerpt\",\"f_ex_font_settings\":\"\",\"f_ex_font_line_height\":\"\",\"f_ex_font_style\":\"\",\"f_ex_font_transform\":\"\",\"f_ex_font_spacing\":\"\",\"f_ex_\":\"\",\"f_btn_font_title\":\"Article read more button\",\"f_btn_font_settings\":\"\",\"f_btn_font_family\":\"\",\"f_btn_font_size\":\"\",\"f_btn_font_line_height\":\"\",\"f_btn_font_style\":\"\",\"f_btn_font_weight\":\"\",\"f_btn_font_transform\":\"\",\"f_btn_font_spacing\":\"\",\"f_btn_\":\"\",\"mix_color\":\"\",\"mix_type\":\"\",\"fe_brightness\":\"1\",\"fe_contrast\":\"1\",\"fe_saturate\":\"1\",\"mix_color_h\":\"\",\"mix_type_h\":\"\",\"fe_brightness_h\":\"1\",\"fe_contrast_h\":\"1\",\"fe_saturate_h\":\"1\",\"m_bg\":\"\",\"shadow_shadow_header\":\"\",\"shadow_shadow_title\":\"Module Shadow\",\"shadow_shadow_size\":\"\",\"shadow_shadow_offset_horizontal\":\"\",\"shadow_shadow_offset_vertical\":\"\",\"shadow_shadow_spread\":\"\",\"shadow_shadow_color\":\"\",\"cat_border\":\"\",\"cat_border_hover\":\"\",\"meta_bg\":\"\",\"author_txt\":\"\",\"author_txt_hover\":\"\",\"com_bg\":\"\",\"com_txt\":\"\",\"shadow_m_shadow_header\":\"\",\"shadow_m_shadow_title\":\"Meta info shadow\",\"shadow_m_shadow_size\":\"\",\"shadow_m_shadow_offset_horizontal\":\"\",\"shadow_m_shadow_offset_vertical\":\"\",\"shadow_m_shadow_spread\":\"\",\"shadow_m_shadow_color\":\"\",\"audio_btn_color\":\"\",\"audio_time_color\":\"\",\"audio_bar_color\":\"\",\"audio_bar_curr_color\":\"\",\"btn_bg\":\"\",\"btn_bg_hover\":\"\",\"btn_txt\":\"\",\"btn_txt_hover\":\"\",\"btn_border\":\"\",\"btn_border_hover\":\"\",\"nextprev_border_h\":\"\",\"pag_border\":\"\",\"pag_h_border\":\"\",\"pag_a_border\":\"\",\"ad_loop\":\"\",\"ad_loop_title\":\"- Advertisement -\",\"ad_loop_repeat\":\"\",\"ad_loop_color\":\"\",\"ad_loop_full\":\"yes\",\"f_ad_font_header\":\"\",\"f_ad_font_title\":\"Ad title text\",\"f_ad_font_settings\":\"\",\"f_ad_font_family\":\"\",\"f_ad_font_size\":\"\",\"f_ad_font_line_height\":\"\",\"f_ad_font_style\":\"\",\"f_ad_font_weight\":\"\",\"f_ad_font_transform\":\"\",\"f_ad_font_spacing\":\"\",\"f_ad_\":\"\",\"ad_loop_disable\":\"\",\"el_class\":\"\",\"td_column_number\":2,\"header_color\":\"\",\"td_ajax_preloading\":\"\",\"td_ajax_filter_type\":\"\",\"td_filter_default_txt\":\"\",\"td_ajax_filter_ids\":\"\",\"color_preset\":\"\",\"border_top\":\"\",\"css\":\"\",\"class\":\"tdi_78\",\"tdc_css_class\":\"tdi_78\",\"tdc_css_class_style\":\"tdi_78_rand_style\"}",
    }
  end

  def parsed_fact_list_page(index_path, page)
    Nokogiri.parse(
      "<html><body>"+JSON.parse(request_fact_page(index_path, page))["td_data"]+"</body></html>"
    )
  end

  def url_extraction_search
    "h3 a"
  end

  def url_extractor(atag)
    atag.attributes['href'].value
  end

  def get_fact_page_urls(page)
    self.index_paths.collect{|index_path|
      extract_urls_from_html(
        parsed_fact_list_page(
          index_path,
          page
        )
      )
    }.flatten.uniq
  end

  def get_claim_review_safely(raw_claim_review)
    claim_review = extract_ld_json_script_block(raw_claim_review["page"], 0)
    claim_review && claim_review["@graph"] && claim_review["@graph"][0] || {}
  end

  def parse_raw_claim_review(raw_claim_review)
    claim_review = get_claim_review_safely(raw_claim_review)
    {
      id: raw_claim_review['url'],
      created_at: (Time.parse(claim_review["datePublished"]) rescue nil),
      claim_review_headline: claim_review["name"].split(" &ndash;")[0..-2].join(" &ndash;"),
      claim_review_body: raw_claim_review["page"].search("div.wp-block-media-text").first.text.strip,
      claim_review_image_url: get_og_image_url(raw_claim_review),
      claim_review_reviewed: claim_review["claimReviewed"],
      claim_review_result: claim_review["reviewRating"] && claim_review["reviewRating"]["alternateName"],
      claim_review_result_score: claim_result_score_from_raw_claim_review(claim_review),
      claim_review_url: raw_claim_review['url'],
      raw_claim_review: claim_review
    }
  end
end
