# frozen_string_literal: true

describe FactCheckOrg do
  describe 'instance' do
    it 'has a hostname' do
      expect(described_class.new.hostname).to(eq('https://www.factcheck.org'))
    end

    it 'has a fact_list_path' do
      expect(described_class.new.fact_list_path(1)).to(eq('/page/1/'))
    end

    it 'has a url_extraction_search' do
      expect(described_class.new.url_extraction_search).to(eq('div#content h3.entry-title a'))
    end

    it 'extracts a url' do
      expect(described_class.new.url_extractor(Nokogiri.parse("<div id='content'><h3 class='entry-title'><a href='/blah'>wow</a></h3></div>").search('a')[0])).to(eq('/blah'))
    end

    it 'rescues against a claim_review_image_url_from_raw_claim_review' do
      expect(described_class.new.claim_review_image_url_from_raw_claim_review({"page" => Nokogiri.parse("<a href='/blah'>wow</a>")})).to(eq(nil))
    end
    
    it 'gets a body from og description' do
      raw = JSON.parse(File.read('spec/fixtures/fact_check_org_raw.json'))
      raw['page'] = Nokogiri.parse(raw['page'])
      expect(described_class.new.get_claim_review_body_from_og_description(raw).class).to(eq(String))
    end

    it 'rescues obviously broken against a claim_review_image_url_from_raw_claim_review' do
      described_class.any_instance.stub(:og_image_url_from_raw_claim_review).with(anything()).and_raise(StandardError)
      expect(described_class.new.claim_review_image_url_from_raw_claim_review({"page" => Nokogiri.parse("<a href='/blah'>wow</a>")})).to(eq(nil))
    end

    it 'parses a raw_claim_review' do
      raw = JSON.parse(File.read('spec/fixtures/fact_check_org_raw.json'))
      raw['page'] = Nokogiri.parse(raw['page'])
      parsed_claim = described_class.new.parse_raw_claim_review(raw)
      expect(parsed_claim.class).to(eq(Hash))
      ClaimReview.mandatory_fields.each do |field|
        expect(QuietHashie[parsed_claim][field].nil?).to(eq(false))
      end
    end

    it 'parses a raw_claim with no author link' do
      raw = JSON.parse(File.read('spec/fixtures/fact_check_org_raw.json'))
      raw['page'].gsub!('meta-author', 'meta-author-name-some-other-class-that-breaks-extraction')
      raw['page'] = Nokogiri.parse(raw['page'])
      parsed_claim = described_class.new.parse_raw_claim_review(raw)
      expect(parsed_claim.class).to(eq(Hash))
      ClaimReview.mandatory_fields.each do |field|
        expect(QuietHashie[parsed_claim][field].nil?).to(eq(false))
      end
    end
  end
end
