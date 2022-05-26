# frozen_string_literal: true

describe Piyaoba do
  before do
    stub_request(:post, "https://www.piyaoba.org/wp-admin/admin-ajax.php").
      with(
        body: /.*/,
        headers: {
    	  'Accept'=>'*/*',
    	  'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
    	  'Content-Length'=>/.*/,
    	  'Host'=>'www.piyaoba.org',
    	  'User-Agent'=>/.*/
        }).
      to_return(status: 200, body: File.read("spec/fixtures/piyaoba_index_raw.json"), headers: {})
  end

  describe 'instance' do
    it 'has a hostname' do
      expect(described_class.new.hostname).to(eq('https://www.piyaoba.org'))
    end

    it 'requests a fact page' do
      expect(described_class.new.request_fact_page(1).class).to(eq(RestClient::Response))      
    end

    it 'returns get_new_fact_page_urls' do
      described_class.any_instance.stub(:get_existing_urls).with(anything).and_return([])
      puts described_class.new.get_new_fact_page_urls(1).inspect
      expect(described_class.new.get_new_fact_page_urls(1)).to(eq(["https://www.piyaoba.org/baby-formula-immigrants/", "https://www.piyaoba.org/white-supremacy-gun/", "https://www.piyaoba.org/gun-crime-biden/", "https://www.piyaoba.org/crt-doj-fbi/", "https://www.piyaoba.org/biden-pedophile-news/", "https://www.piyaoba.org/biden-resign-hunter/", "https://www.piyaoba.org/obama-trump-vaccine/", "https://www.piyaoba.org/musk-twitter-follower/", "https://www.piyaoba.org/trump-contempt-fine/"]))
    end

    it 'parses a raw_claim_review' do
      raw = JSON.parse(File.read('spec/fixtures/piyaoba_raw.json'))
      raw['page'] = Nokogiri.parse(raw['page'])
      parsed_claim = described_class.new.parse_raw_claim_review(raw)
      expect(parsed_claim.class).to(eq(Hash))
      ClaimReview.mandatory_fields.each do |field|
        expect(QuietHashie[parsed_claim][field].nil?).to(eq(false))
      end
    end
  end
end
