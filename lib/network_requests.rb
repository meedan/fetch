module NetworkRequests

  def make_request
    retry_count = 0
    begin
      yield
    rescue RestClient::BadGateway, RestClient::NotFound, SocketError, Errno::ETIMEDOUT => e
      if retry_count < 3
        retry_count += 1
        sleep(1)
        retry
      else
        Error.log(e)
        return nil
      end
    end
  end

  def request(method, url, payload=nil)
    make_request do
      headers = @user_agent ? {user_agent: @user_agent} : {}
      proxy = @proxy ? @proxy : nil
      RestClient::Request.execute(
        method: method,
        url: @escape_url_in_request ? URI::Parser.new.escape(url) : url,
        payload: payload,
        cookies: @cookies,
        headers: headers,
        proxy: proxy
      )
    end
  end

  def post_url(url, body)
    request(:post, url, body)
  end

  def get_url(url)
    request(:get, url)
  end

end