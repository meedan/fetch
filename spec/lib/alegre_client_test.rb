describe AlegreClient do
  before do
    stub_request(:get, "http://alegre.local/article/?url=http://example.com/link").
      with(
        headers: {
      	  'Accept'=>'*/*',
      	  'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
      	  'Host'=>'alegre.qa',
          "User-Agent": /.*/
        }).
      to_return(status: 200, body: '{"title":"AFP Covid-19 verification hub"}', headers: {})
  end

  describe 'class' do
    it 'expects an alegre response' do
      response = {"title"=>"AFP Covid-19 verification hub"}
      expect(AlegreClient.get_enrichment_for_url("http://example.com/link")).to(eq(response))
    end
  end
end
