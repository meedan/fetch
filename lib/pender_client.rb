class PenderClient
  def self.host
    Settings.get("pender_host_url")
  end

  def self.get_enrichment_for_url(url)
    JSON.parse(
      RestClient.get(
        self.host+"api/medias.json?url=#{CGI.escape(url)}",
        {
          content_type: 'application/json',
          'X-Pender-Token' => Settings.get("pender_api_key")
        }
      )
    )
  rescue => e
    Error.log(e, {url: url}) if (e.class.ancestors.include?(RestClient::Exception) && (e.http_code||500) >= 500 || !e.class.ancestors.include?(RestClient::Exception))
    return {}
  end
end