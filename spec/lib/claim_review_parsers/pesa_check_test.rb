# frozen_string_literal: true

describe PesaCheck do
  before do
    stub_request(:get, "https://api.rss2json.com/v1/api.json?rss_url=https://medium.com/feed/@pesacheck").
      with(
        headers: {
    	  'Accept'=>'*/*',
    	  'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
    	  'Host'=>'api.rss2json.com',
        "User-Agent": /.*/
        }).
      to_return(status: 200, body: File.read("spec/fixtures/pesa_check_index_raw.json"), headers: {})
  end
  describe 'instance' do
    it 'runs get_claim_reviews' do
      described_class.any_instance.stub(:store_to_db).with(anything, anything).and_return(true)
      described_class.any_instance.stub(:get_existing_urls).with(anything).and_return([])
      expect(described_class.new.get_claim_reviews.class).to(eq(Array))
    end

    it 'parses a raw_claim_review' do
      raw = JSON.parse(File.read('spec/fixtures/pesa_check_raw.json'))
      parsed_claim = described_class.new.parse_raw_claim_review(raw)
      expect(parsed_claim.class).to(eq(Hash))
      ClaimReview.mandatory_fields.each do |field|
        expect(QuietHashie[parsed_claim][field].nil?).to(eq(false))
      end
    end
  end
end
