# frozen_string_literal: true

describe VietFactCheck do
  before do
    stub_request(:post, "https://vietfactcheck.org/?infinity=scrolling").
      with(
        body: /.*/,
        headers: {
    	  'Accept'=>'*/*',
    	  'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
    	  'Content-Length'=>/.*/,
    	  'Host'=>'vietfactcheck.org',
    	  'User-Agent'=>/.*/
        }).
      to_return(status: 200, body: File.read("spec/fixtures/viet_fact_check_index_raw.json"), headers: {})
  end

  describe 'instance' do
    it 'has a hostname' do
      expect(described_class.new.hostname).to(eq('https://vietfactcheck.org'))
    end

    it 'requests a fact page' do
      expect(described_class.new.request_fact_page(1).class).to(eq(RestClient::Response))      
    end

    it 'returns get_new_fact_page_urls' do
      described_class.any_instance.stub(:get_existing_urls).with(anything).and_return([])
      expect(described_class.new.get_new_fact_page_urls(1).length).to(eq(10))
    end
    
    it "returns nil for bad lookup on claim review result" do
      expect(described_class.new.claim_review_result_from_raw_claim_review({"page" => Nokogiri.parse("<html><body></body></html>")})).to(eq([nil, nil]))
    end

    it 'parses a raw_claim_review' do
      raw = JSON.parse(File.read('spec/fixtures/viet_fact_check_raw.json'))
      raw['page'] = Nokogiri.parse(raw['page'])
      parsed_claim = described_class.new.parse_raw_claim_review(raw)
      expect(parsed_claim.class).to(eq(Hash))
      ClaimReview.mandatory_fields.each do |field|
        expect(QuietHashie[parsed_claim][field].nil?).to(eq(false))
      end
    end
  end
end
