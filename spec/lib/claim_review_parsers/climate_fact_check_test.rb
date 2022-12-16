# frozen_string_literal: true

describe ClimateFactCheck do
  before do
    ClimateFactCheck.new.hostnames.each do |hostname|
      stub_request(:get, hostname+"/page/1/").
        with(
          headers: {
      	  'Accept'=>'*/*',
      	  'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
      	  'Host'=>/.*/,
          "User-Agent": /.*/
          }).
        to_return(status: 200, body: File.read("spec/fixtures/climate_fact_check_index.html"), headers: {})
    end
  end
  describe 'instance' do
    it 'runs get_fact_page_urls across multiple hostnames' do
      response = described_class.new.get_fact_page_urls(1)
      expect(response.class).to(eq(Array))
    end
    it 'parses a raw_claim_review' do
      raw = JSON.parse(File.read('spec/fixtures/climate_fact_check_raw.json'))
      raw['page'] = Nokogiri.parse(raw['page'])
      parsed_claim = described_class.new.parse_raw_claim_review(raw)
      expect(parsed_claim.class).to(eq(Hash))
      ClaimReview.mandatory_fields.each do |field|
        expect(QuietHashie[parsed_claim][field].nil?).to(eq(false))
      end
    end
  end
end
