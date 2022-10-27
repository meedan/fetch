# frozen_string_literal: true

describe NewtralFactCheck do
  describe 'instance' do
    it 'has a relevant_sitemap_subpath' do
      expect(described_class.new.relevant_sitemap_subpath).to(eq("www.newtral.es/factcheck"))
    end

    it 'parses a raw_claim_review' do
      raw = JSON.parse(File.read('spec/fixtures/newtral_fakes_raw.json'))
      raw['page'] = Nokogiri.parse(raw['page'])
      parsed_claim = described_class.new.parse_raw_claim_review(raw)
      expect(parsed_claim.class).to(eq(Hash))
      ClaimReview.mandatory_fields.each do |field|
        expect(QuietHashie[parsed_claim][field].nil?).to(eq(false))
      end
    end
  end
end
