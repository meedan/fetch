# frozen_string_literal: true

describe Thip do
  before do
    stub_request(:get, Thip.new.hostname+"/wp-json/wp/v2/posts?categories=27,28,162,164,166,168,1886,1994,520&per_page=100&page=1").
      with(
        headers: {
    	  'Accept'=>'*/*',
    	  'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
     	  'Host'=>'www.thip.media',
    	  'User-Agent'=>/.*/
        }).
        to_return(status: 200, body: JSON.parse(File.read("spec/fixtures/thip_index_raw.json")), headers: {})
  end

  describe 'instance' do
    it 'has a hostname' do
      expect(described_class.new.hostname).to(eq('https://www.thip.media'))
    end

    it 'has a fact_list_path' do
      expect(described_class.new.fact_list_path(1)).to(eq('/wp-json/wp/v2/posts?categories=27,28,162,164,166,168,1886,1994,520&per_page=100&page=1'))
    end

    it 'extracts a url' do
      expect(described_class.new.url_extractor([{"url" => "/blah"}])).to(eq([{"url" => "/blah"}]))
    end

    it 'extracts raw responses from get_new_fact_page_urls' do
      described_class.any_instance.stub(:get_fact_page_urls).with(1).and_return([{"content" => {"url" => "/blah"}}])
      described_class.any_instance.stub(:get_existing_urls).with(anything()).and_return([])
      expect(described_class.new.get_new_fact_page_urls(1)).to(eq([{"content"=>{"url"=>"/blah"}}]))
    end

    it 'extracts parsed_fact_page results' do
      keys = [:author, :author_link, :claim_review_body, :claim_review_headline, :claim_review_image_url, :claim_review_result, :claim_review_url, :created_at, :id, :raw_claim_review].sort
      response = described_class.new.parsed_fact_page(JSON.parse(File.read('spec/fixtures/thip_raw.json'))["raw_response"])
      expect(response[0]).to(eq('https://www.thip.media/health-news-fact-check/fact-check-can-vitamin-d-cure-cancer/36698/'))
      expect(response[1].class).to(eq(Hash))
      expect(response[1].keys.sort).to(eq(keys))
    end
    
    it 'parses a raw_claim_review' do
      raw = JSON.parse(File.read('spec/fixtures/thip_raw.json'))
      parsed_claim = Thip.new.parse_raw_claim_review(raw)
      expect(parsed_claim.class).to(eq(Hash))
      ClaimReview.mandatory_fields.each do |field|
        expect(QuietHashie[parsed_claim][field].nil?).to(eq(false))
      end
    end
  end
end
