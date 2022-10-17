# frozen_string_literal: true

describe Fatabyyano do
  before do
    stub_request(:post, "https://fatabyyano.net/wp-admin/admin-ajax.php").
      with(
        body: /.*/,
        headers: {
    	  'Accept'=>'*/*',
    	  'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
    	  'Content-Length'=>/.*/,
    	  'Host'=>'fatabyyano.net',
    	  'User-Agent'=>/.*/
        }).
      to_return(status: 200, body: File.read("spec/fixtures/fatabyyano_index_raw.html"), headers: {})
  end

  describe 'instance' do
    it 'has a hostname' do
      expect(described_class.new.hostname).to(eq('https://fatabyyano.net'))
    end

    it 'requests a fact page' do
      expect(described_class.new.request_fact_page(1).class).to(eq(RestClient::Response))      
    end

    it 'returns get_new_fact_page_urls' do
      described_class.any_instance.stub(:get_existing_urls).with(anything).and_return([])
      expect(described_class.new.get_new_fact_page_urls(1)).to(eq(["https://fatabyyano.net/%d9%87%d8%b0%d8%a7-%d8%a7%d9%84%d9%85%d9%82%d8%b7%d8%b9-%d8%a7%d9%84%d8%b0%d9%8a-%d9%82%d9%8a%d9%84-%d8%a3%d9%86%d9%87-%d8%b5%d9%88%d9%91%d8%b1-%d8%ad%d8%af%d9%8a%d8%ab%d9%8b%d8%a7-%d9%84%d8%b5%d8%af/", "https://fatabyyano.net/%d9%87%d8%b0%d8%a7-%d8%a7%d9%84%d9%81%d9%8a%d8%af%d9%8a%d9%88-%d9%82%d8%af%d9%8a%d9%85-%d9%85%d9%86-%d8%a7%d9%84%d9%8a%d9%85%d9%86-%d9%88%d9%84%d9%8a%d8%b3-%d9%84%d9%87-%d8%b9%d9%84%d8%a7%d9%82%d8%a9/", "https://fatabyyano.net/%d9%87%d8%b0%d8%a7-%d8%a7%d9%84%d9%85%d9%82%d8%b7%d8%b9-%d9%84%d8%a7-%d9%8a%d8%b8%d9%87%d8%b1-%d8%b5%d8%a7%d8%b1%d9%88%d8%ae%d8%a7-%d8%b1%d9%88%d8%b3%d9%8a%d8%a7-%d8%a8%d9%84-%d9%85%d8%b9%d8%af%d8%a7/", "https://fatabyyano.net/%d9%87%d8%b0%d9%87-%d8%a7%d9%84%d8%b5%d9%88%d8%b1%d8%a9-%d9%85%d9%86-%d8%b9%d8%a7%d9%85-2017%d8%8c-%d9%88%d9%84%d9%8a%d8%b3%d8%aa-%d9%85%d9%86-%d8%aa%d8%ad%d8%b1%d9%83-%d8%a7%d9%84%d8%b7%d8%a7%d8%a6/", "https://fatabyyano.net/%d9%87%d8%b0%d8%a7-%d8%a7%d9%84%d9%85%d9%82%d8%b7%d8%b9-%d9%82%d8%af%d9%8a%d9%85%d8%8c-%d9%88%d9%84%d8%a7-%d9%8a%d8%b8%d9%87%d8%b1-%d8%b3%d8%b1%d9%82%d8%a9-%d9%85%d8%aa%d8%a7%d8%ac%d8%b1-%d9%81%d9%8a/", "https://fatabyyano.net/%d9%87%d8%b0%d8%a7-%d8%a7%d9%84%d9%85%d9%82%d8%b7%d8%b9-%d9%82%d8%af%d9%8a%d9%85-%d9%88%d9%84%d8%a7-%d9%8a%d8%b8%d9%87%d8%b1-%d9%88%d8%b5%d9%88%d9%84-%d8%b7%d8%a7%d8%a6%d8%b1%d8%a9-%d8%a3%d9%85%d8%b1/", "https://fatabyyano.net/%d9%87%d8%b0%d8%a7-%d8%a7%d9%84%d9%85%d9%82%d8%b7%d8%b9-%d9%85%d9%82%d8%aa%d8%a8%d8%b3-%d9%85%d9%86-%d9%84%d8%b9%d8%a8%d8%a9-%d9%81%d9%8a%d8%af%d9%8a%d9%88-%d9%88%d9%84%d8%a7-%d9%8a%d8%b8%d9%87%d8%b1/", "https://fatabyyano.net/%d9%85%d9%82%d8%b7%d8%b9-%d8%a7%d9%84%d8%a7%d8%b4%d8%aa%d8%a8%d8%a7%d9%83%d8%a7%d8%aa-%d9%85%d9%86%d8%b0-%d8%a7%d8%ba%d8%b3%d8%b7%d8%b3/", "https://fatabyyano.net/%d9%87%d8%b0%d9%87-%d8%a7%d9%84%d8%b5%d9%88%d8%b1%d8%a9-%d9%85%d9%81%d8%a8%d8%b1%d9%83%d8%a9-%d9%88%d9%84%d8%a7-%d8%aa%d8%b8%d9%87%d8%b1-%d8%a7%d9%84%d8%ad%d9%84%d8%a8%d9%88%d8%b3%d9%8a-%d9%8a%d8%b1/"]))
    end

    it 'parses a raw_claim_review' do
      raw = JSON.parse(File.read('spec/fixtures/fatabyyano_raw.json'))
      raw['page'] = Nokogiri.parse(raw['page'])
      parsed_claim = described_class.new.parse_raw_claim_review(raw)
      expect(parsed_claim.class).to(eq(Hash))
      ClaimReview.mandatory_fields.each do |field|
        expect(QuietHashie[parsed_claim][field].nil?).to(eq(false))
      end
    end
  end
end
