describe AlegreClient do
  before do
    stub_request(:post, "#{Settings.get_safe_url("alegre_host_url")}article/").
      with(
        body: {"url"=>"http://example.com/link"},
        headers: {
          'Accept'=>'*/*',
          'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          "User-Agent": /.*/
        }).
      to_return(status: 200, body: '{"title":"AFP Covid-19 verification hub"}', headers: {})
  end

  describe 'class' do
    it 'expects an alegre response' do
      response = {"title"=>"AFP Covid-19 verification hub"}
      expect(AlegreClient.get_enrichment_for_url("http://example.com/link")).to(eq(response))
    end

    it 'degrades gracefully when Alegre errors out' do
      RestClient::ServiceUnavailable.any_instance.stub(:http_code).and_return(500)
      RestClient::Request.stub(:execute).and_raise(RestClient::ServiceUnavailable.new)
      expect(AlegreClient.get_enrichment_for_url("http://example.com/link")).to(eq({}))
    end
  end
end
