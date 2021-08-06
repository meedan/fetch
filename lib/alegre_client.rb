class AlegreClient
  def self.host
    Settings.get("alegre_host_url")
  end

  def self.get_enrichment_for_url(url)
    JSON.parse(RestClient.get(self.host+"/article/?url=#{url}"))
  end
end