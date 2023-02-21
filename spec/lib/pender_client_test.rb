# stub_request(:get, ).
#   with(
#     headers: {
#     'Accept'=>'*/*',
#     'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
#     'Content-Type'=>'application/json',
#     'Host'=>'pender.local',
#     'User-Agent'=>'rest-client/2.1.0 (darwin19.3.0 x86_64) ruby/2.7.0p0',
#     'X-Pender-Token'=>''
#     }).
#   to_return(status: 200, body: "", headers: {})
#
#
describe PenderClient do
  before do
    stub_request(:get, "#{Settings.get_safe_url("pender_host_url")}api/medias.json?url=https://twitter.com/meedan/status/773947372527288320/").
      with(
        headers: {
          'Accept'=>'*/*',
          'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          "User-Agent": /.*/
        }).
      to_return(status: 200, body: File.read("spec/fixtures/pender_response.json"), headers: {})
    stub_request(:get, "#{Settings.get_safe_url("pender_host_url")}api/medias.json?url=http://example.com/link").
      with(
        headers: {
          'Accept'=>'*/*',
          'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          "User-Agent": /.*/
        }).
      to_return(status: 200, body: File.read("spec/fixtures/pender_response.json"), headers: {})
  end

  describe 'class' do
    it 'expects no pender response' do
      expect(PenderClient.get_enrichment_for_url("http://example.com/link")).to(eq({}))
    end

    it 'expects a pender response' do
      expect(PenderClient.get_enrichment_for_url("https://twitter.com/meedan/status/773947372527288320/")).to(eq(JSON.parse(File.read("spec/fixtures/pender_response.json"))))
    end

    it 'degrades gracefully when Alegre errors out' do
      RestClient::ServiceUnavailable.any_instance.stub(:http_code).and_return(500)
      RestClient::Request.stub(:execute).and_raise(RestClient::ServiceUnavailable.new)
      expect(PenderClient.get_enrichment_for_url("https://twitter.com/meedan/status/773947372527288320/")).to(eq({}))
    end
  end
end
