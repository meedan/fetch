class PenderClient
  def self.host
    Settings.get_safe_url("pender_host_url")
  end

  def self.get_enrichment_for_url(url)
    parsed_url = URI.parse(url) rescue nil
    if self.allowed_domain(parsed_url)
      JSON.parse(
        RestClient::Request.execute(
          method: :get,
          url: self.host+"api/medias.json?url=#{CGI.escape(url)}",
          open_timeout: 10,
          read_timeout: 10,
          headers: {
            content_type: 'application/json',
            'X-Pender-Token' => Settings.get("pender_api_key")
          }
        )
      )
    else
      return {}
    end
  rescue => e
    Error.log("Pender Client Failed to Get URL!", {error: e.to_s, url: url})
    Error.log(e, {url: url})#lets just throw all errors until we figure out whats going on here.# if (e.class.ancestors.include?(RestClient::Exception) && (e.http_code||500) >= 500 || !e.class.ancestors.include?(RestClient::Exception))
    return {}
  end

  def self.allowed_domain(parsed_url)
    if parsed_url
      self.allowed_hostnames.each do |hostname|
        if parsed_url.hostname.include?(hostname)
          return true
        end
      end
    end
    return false
  end

  def self.allowed_hostnames
    %w{
      twitter.com
      perma.cc
      www.facebook.com
      www.youtube.com
      t.co
      web.archive.org
      www.google.com
      www.tumblr.com
      youtu.be
      t.me
      web.whatsapp.com
      drive.google.com
      bit.ly
      www.linkedin.com
      docs.google.com
      goo.gl
      web.facebook.com
      www.dailymail.co.uk
      www.tiktok.com
      www.altnews.in
      www.flickr.com
      archive.st
      tinyurl.com
      webcache.googleusercontent.com
      archive.org
      instagram.com
      m.facebook.com
      plus.google.com
      realrawnews.com
      www.thesun.co.uk
      medium.com
      vimeo.com
      www.mirror.co.uk
      www.dailymotion.com
      www.breitbart.com
      metro.co.uk
      imgur.com
      fb.watch
      www.thedailybeast.com
      www.washingtonexaminer.com
      vk.com
      rb.gy
      www.sun.ac.za
    }
  end
end
