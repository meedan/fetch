module HTMLMetadataHelpers

  def parse_script_block(script_block)
    if !script_block.nil?
      begin
        parsed = JSON.parse(script_block.text)
        return parsed
      rescue JSON::ParserError
        return nil
      end
    end
  end

  def extract_ld_json_script_block(page, index, search_path="script")
    script_block = page && extract_all_ld_json_script_blocks(page, search_path)[index]
    parse_script_block(script_block)
  end

  def keywords_from_raw_claim_review(raw_claim_review)
    raw_claim_review["page"].search("meta").select{|x|
      x.attributes["name"] && x.attributes["name"].value == "keywords"
    }.first.attributes["content"].value
  end

  def og_timestamps_from_raw_claim_review(raw_claim_review)
    raw_claim_review["page"].search("meta").select{|x|
      x.attributes["property"] && x.attributes["property"].value.include?("_time")
    }.collect{|x|
      Time.parse(x.attributes["content"].value) rescue nil
    }.compact
  end

  def value_from_og_tag(og_tag)
    og_tag.attributes["content"].value if og_tag
  end

  def search_for_og_tags(page, og_tags)
    page.search("meta").select{|x| x.attributes["property"] && og_tags.include?(x.attributes["property"].value)}.compact.first
  end

  def og_date_from_raw_claim_review(raw_claim_review)
    value_from_og_tags(raw_claim_review, ["article:published_time", "article:modified_time", "article:updated_time"])
  end

  def og_title_from_raw_claim_review(raw_claim_review)
    value_from_og_tags(raw_claim_review, ["og:title"])
  end

  def get_og_image_url(raw_claim_review)
    value_from_og_tag(search_for_og_tags(raw_claim_review["page"], ["og:image"])) rescue nil
  end

  def value_from_og_tags(raw_claim_review, og_tags)
    value_from_og_tag(
      search_for_og_tags(raw_claim_review["page"], og_tags)
    )
  end

  def extract_author_value(article, key, prefix="")
    if article["author"].class == Hash
      return prefix+([article["author"][key]].flatten.first.to_s)
    elsif article["author"].class == Array
      return prefix+([article["author"][0][key]].flatten.first.to_s)
    end
  end

  def get_author_and_link_from_article(article, hostname="")
    if article && article["author"]
      if article["author"].class == Hash || article["author"].class == Array
        return [extract_author_value(article, "name"), extract_author_value(article, "url", hostname)]
      else
        return [nil,nil]
      end
    end
  end

  def extract_all_ld_json_script_blocks(page, search_path="script")
    page.search(search_path).select{|x| x.attributes["type"] && x.attributes["type"].value == "application/ld+json"}
  end

end