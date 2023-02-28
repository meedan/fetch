# frozen_string_literal: true

describe Estadao do
  before do
    stub_request(:get, "https://www.estadao.com.br/").
      with(
        headers: {
    	  'Accept'=>'*/*',
    	  'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
    	  'Host'=>'www.estadao.com.br',
        }).
      to_return(status: 200, body: '<html><link rel="shortcut icon" href="/pf/resources/favicon.ico?d=556"/></html>', headers: {})
  end

  describe 'instance' do
    it 'has a hostname' do
      expect(described_class.new.hostname).to(eq('https://www.estadao.com.br'))
    end

    it 'has a fact_list_path' do
      expect(described_class.new.fact_list_path(1)).to(eq('/pf/api/v3/content/fetch/story-feed-query?query=%7B%22body%22:%22%7B%5C%22query%5C%22:%7B%5C%22bool%5C%22:%7B%5C%22must%5C%22:[%7B%5C%22term%5C%22:%7B%5C%22type%5C%22:%5C%22story%5C%22%7D%7D,%7B%5C%22term%5C%22:%7B%5C%22revision.published%5C%22:1%7D%7D,%7B%5C%22nested%5C%22:%7B%5C%22path%5C%22:%5C%22taxonomy.sections%5C%22,%5C%22query%5C%22:%7B%5C%22bool%5C%22:%7B%5C%22must%5C%22:[%7B%5C%22regexp%5C%22:%7B%5C%22taxonomy.sections._id%5C%22:%5C%22.*estadao-verifica.*%5C%22%7D%7D]%7D%7D%7D%7D]%7D%7D%7D%22,%22size%22:0,%22sort%22:%22display_date:desc,%20first_publish_date:desc%22%7D&d=556&_website=estadao'))
    end

    it 'extracts a url' do
      expect(described_class.new.url_extractor(JSON.parse(File.read("spec/fixtures/estadao_index.json"))).count).to(eq(8))
    end

    it 'still plucks an image when claimreview object does not contain one' do
      described_class.any_instance.stub(:extract_ld_json_script_block).with(anything, anything).and_return(nil)
      raw = JSON.parse(File.read('spec/fixtures/estadao_raw.json'))
      raw['page'] = Nokogiri.parse(raw['page'])
      parsed_claim = described_class.new.parse_raw_claim_review(raw)
      expect(parsed_claim[:claim_review_image_url].class).to(eq(String))
      described_class.any_instance.unstub(:extract_ld_json_script_block)
    end

    it 'parses a raw_claim_review' do
      raw = JSON.parse(File.read('spec/fixtures/estadao_raw.json'))
      raw['page'] = Nokogiri.parse(raw['page'])
      parsed_claim = described_class.new.parse_raw_claim_review(raw)
      expect(parsed_claim.class).to(eq(Hash))
      ClaimReview.mandatory_fields.each do |field|
        expect(QuietHashie[parsed_claim][field].nil?).to(eq(false))
      end
    end
  end
end
