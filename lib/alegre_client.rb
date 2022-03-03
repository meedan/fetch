class AlegreClient
  def self.host
    Settings.get("alegre_host_url")
  end

  def self.get_enrichment_for_url(url)
    JSON.parse(
      RestClient::Request.execute(
        :method => :post,
        :url => self.host+"article/",
        :payload => {url: url}.to_json,
        :headers => {content_type: 'application/json'},
        :timeout => 10,
        :open_timeout => 10
      )
    )
  rescue => e
    Error.log(e, {url: url}) if (e.class.ancestors.include?(RestClient::Exception) && (e.http_code||500) >= 500 || !e.class.ancestors.include?(RestClient::Exception))
    return {}
  end
end