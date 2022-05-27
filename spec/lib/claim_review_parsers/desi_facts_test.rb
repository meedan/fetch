# frozen_string_literal: true

describe DesiFacts do
  before do
    stub_request(:get, "https://www.desifacts.org/sitemap.xml").
      with(
        headers: {
    	  'Accept'=>'*/*',
    	  'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
    	  'Host'=>'www.desifacts.org',
        "User-Agent": /.*/
        }).
      to_return(status: 200, body: File.read("spec/fixtures/desi_facts_index_raw.xml"), headers: {})
    stub_request(:get, "https://bn.desifacts.org/sitemap.xml").
      with(
        headers: {
    	  'Accept'=>'*/*',
    	  'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
    	  'Host'=>'bn.desifacts.org',
        "User-Agent": /.*/
        }).
      to_return(status: 200, body: File.read("spec/fixtures/desi_facts_index_raw.xml"), headers: {})
    stub_request(:get, "https://hi.desifacts.org/sitemap.xml").
      with(
        headers: {
    	  'Accept'=>'*/*',
    	  'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
    	  'Host'=>'hi.desifacts.org',
        "User-Agent": /.*/
        }).
      to_return(status: 200, body: File.read("spec/fixtures/desi_facts_index_raw.xml"), headers: {})
  end
  describe 'instance' do
    it 'has hostnames' do
      hostnames = [
      "https://www.desifacts.org",
      "https://hi.desifacts.org",
      "https://bn.desifacts.org",
    ]
      expect(described_class.new.hostnames).to(eq(hostnames))
    end

    it 'runs get_claim_reviews' do
      described_class.any_instance.stub(:get_existing_urls).with(anything).and_return(described_class.new.get_article_urls)
      expect(described_class.new.get_claim_reviews).to(eq([]))
    end

    it 'parses a raw_claim_review' do
      raw = JSON.parse(File.read('spec/fixtures/desi_facts_raw.json'))
      raw['page'] = Nokogiri.parse(raw['page'])
      parsed_claim = described_class.new.parse_raw_claim_review(raw)
      expect(parsed_claim.class).to(eq(Hash))
      ClaimReview.mandatory_fields.each do |field|
        expect(QuietHashie[parsed_claim][field].nil?).to(eq(false))
      end
    end
  end
end
