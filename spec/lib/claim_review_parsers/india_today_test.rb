# frozen_string_literal: true

describe IndiaToday do
  describe 'instance' do
    it 'has a hostname' do
      expect(described_class.new.hostname).to(eq('https://www.indiatoday.in'))
    end

    it 'has a fact_list_path' do
      expect(described_class.new.fact_list_path(1)).to(eq('/api/ajax/newslist?page=0&id=1792990&type=story&display=12'))
    end

    it 'extracts a url' do
      expect(described_class.new.url_extractor({"data" => {"content" => [{"canonical_url" => "/blah"}]}})).to(eq(["https://www.indiatoday.in/blah"]))
    end

    it 'parses a raw_claim_review' do
      raw = JSON.parse(File.read('spec/fixtures/india_today_raw.json'))
      raw['page'] = Nokogiri.parse(raw['page'])
      parsed_claim = described_class.new.parse_raw_claim_review(raw)
      expect(parsed_claim.class).to(eq(Hash))
      ClaimReview.mandatory_fields.each do |field|
        expect(QuietHashie[parsed_claim][field].nil?).to(eq(false))
      end
    end

  end
end
