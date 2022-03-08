# frozen_string_literal: true

describe VeraFiles do
  describe 'instance' do
    it 'has a hostname' do
      expect(described_class.new.hostname).to(eq('https://verafiles.org'))
    end

    it 'has a fact_list_path' do
      expect(described_class.new.fact_list_path(1)).to(eq('/specials/fact-check?ccm_paging_p=1'))
    end

    it 'has a url_extraction_search' do
      expect(described_class.new.url_extraction_search).to(eq('div.collection__main div.page-list-article div.page-list-article__title a'))
    end

    it 'extracts a url' do
      expect(described_class.new.url_extractor(Nokogiri.parse("<a href='https://verafiles.org/blah'>wow</a>").search('a')[0])).to(eq('https://verafiles.org/blah'))
    end

    it 'rescues against a claim_review_image_url_from_raw_claim_review' do
      expect(described_class.new.claim_review_image_url_from_raw_claim_review({"page" => Nokogiri.parse("<a href='/blah'>wow</a>")})).to(eq(nil))
    end

    it 'parses a raw_claim_review' do
      raw = JSON.parse(File.read('spec/fixtures/vera_files_raw.json'))
      raw['page'] = Nokogiri.parse(raw['page'])
      parsed_claim = described_class.new.parse_raw_claim_review(raw)
      expect(parsed_claim.class).to(eq(Hash))
      ClaimReview.mandatory_fields.each do |field|
        expect(QuietHashie[parsed_claim][field].nil?).to(eq(false))
      end
    end
  end
end
