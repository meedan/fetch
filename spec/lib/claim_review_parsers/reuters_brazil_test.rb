# frozen_string_literal: true

describe ReutersBrazil do
  describe 'instance' do
    it 'has a hostname' do
      expect(described_class.new.hostname).to(eq('https://www.reuters.com'))
    end

    it 'has a fact_list_path' do
      expect(described_class.new.fact_list_path(1)).to(eq('/pf/api/v3/content/fetch/articles-by-section-alias-or-id-v1?query=%7B%22arc-site%22%3A%22reuters%22%2C%22offset%22%3A0%2C%22requestId%22%3A2%2C%22section_id%22%3A%22%2Ffact-check%2Fportugues%2F%22%2C%22size%22%3A20%2C%22uri%22%3A%22%2Ffact-check%2Fportugues%2F%22%2C%22website%22%3A%22reuters%22%7D&d=176&_website=reuters'))
    end

    it 'extracts a url' do
      expect(described_class.new.url_extractor({"result" => {"articles" => [{"a" => "b"}]}})).to(eq([{"a" => "b"}]))
    end

    it 'parses a raw_claim_review' do
      raw = JSON.parse(File.read('spec/fixtures/reuters_brazil_raw.json'))
      raw['page'] = Nokogiri.parse(raw['page'])
      parsed_claim = described_class.new.parse_raw_claim_review(raw)
      expect(parsed_claim.class).to(eq(Hash))
      ClaimReview.mandatory_fields.each do |field|
        expect(QuietHashie[parsed_claim][field].nil?).to(eq(false))
      end
    end
  end
end
