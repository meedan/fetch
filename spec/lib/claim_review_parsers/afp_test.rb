# frozen_string_literal: true

describe AFP do
  describe 'instance' do
    it 'has a hostname' do
      expect(described_class.new.hostname).to(eq('https://factcheck.afp.com'))
    end

    it 'has a fact_list_path' do
      expect(AFPChecamos.new.fact_list_path(1)).to(eq('/list?page=0'))
    end

    it 'has a url_extraction_search' do
      expect(AFPChecamos.new.url_extraction_search).to(eq('main.container div.card a'))
    end

    it 'extracts a url' do
      expect(AFPChecamos.new.url_extractor(Nokogiri.parse("<a href='/blah'>wow</a>").search('a')[0])).to(eq('https://checamos.afp.com/blah'))
    end

    it 'rescues against a claim_review_image_url_from_raw_claim_review' do
      expect(described_class.new.claim_review_image_url_from_raw_claim_review({"page" => Nokogiri.parse("<a href='/blah'>wow</a>")})).to(eq(nil))
    end

    it 'rescues obviously broken against a claim_review_image_url_from_raw_claim_review' do
      described_class.any_instance.stub(:og_image_url_from_raw_claim_review).with(anything()).and_raise(StandardError)
      expect(described_class.new.claim_review_image_url_from_raw_claim_review({"page" => Nokogiri.parse("<a href='/blah'>wow</a>")})).to(eq(nil))
    end

    it 'parses a raw_claim_review' do
      raw = JSON.parse(File.read('spec/fixtures/afp_raw.json'))
      raw['page'] = Nokogiri.parse(raw['page'])
      parsed_claim = described_class.new.parse_raw_claim_review(raw)
      expect(parsed_claim.class).to(eq(Hash))
      ClaimReview.mandatory_fields.each do |field|
        expect(Hashie::Mash[parsed_claim][field].nil?).to(eq(false))
      end
    end

    it 'parses a raw_claim with no author link' do
      raw = JSON.parse(File.read('spec/fixtures/afp_raw.json'))
      raw['page'].gsub!('meta-author', 'meta-author-name-some-other-class-that-breaks-extraction')
      raw['page'] = Nokogiri.parse(raw['page'])
      parsed_claim = described_class.new.parse_raw_claim_review(raw)
      expect(parsed_claim.class).to(eq(Hash))
      ClaimReview.mandatory_fields.each do |field|
        expect(Hashie::Mash[parsed_claim][field].nil?).to(eq(false))
      end
    end
  end
end
