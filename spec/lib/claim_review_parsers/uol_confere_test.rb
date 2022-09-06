# frozen_string_literal: true

describe UOLConfere do
  describe 'instance' do
    it 'has a fact_list_path' do
      expect(described_class.new.fact_list_path("blah")).to(eq('/confere/?next=blah'))
    end

    it 'has a url_extraction_search' do
      expect(described_class.new.url_extraction_search).to(eq("div.collection-standard section.latest-news-banner div.container section.results-index div.thumbnails-item a"))
    end

    it 'parses a raw_claim_review' do
      raw = JSON.parse(File.read('spec/fixtures/uol_comprova_raw.json'))
      raw['page'] = Nokogiri.parse(raw['page'])
      parsed_claim = described_class.new.parse_raw_claim_review(raw)
      expect(parsed_claim.class).to(eq(Hash))
      ClaimReview.mandatory_fields.each do |field|
        expect(QuietHashie[parsed_claim][field].nil?).to(eq(false))
      end
    end
  end
end
