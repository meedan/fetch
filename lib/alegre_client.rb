class AlegreClient
  def self.host
    Settings.get("alegre_host_url")
  end

  def self.get_enrichment_for_url(url)
    JSON.parse(
      RestClient.post(
        self.host+"/article/",
        {url: url},
        {content_type: 'application/json'}
      )
    )
  end
end