class AlegreClient
  def self.host
    Settings.get("alegre_host_url")
  end

  def self.get_enrichment_for_url(url)
    JSON.parse(
      RestClient.post(
        self.host+"/article/",
        {url: url}.to_json,
        {content_type: 'application/json'}
      )
    )
  rescue => e
    Error.log(e, {url: url}) if e.class.ancestors.include?(RestClient::Exception) && e.http_code >= 500
    return {}
  end
end