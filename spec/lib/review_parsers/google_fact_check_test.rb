# frozen_string_literal: true

describe GoogleFactCheck do
  describe 'instance' do
    it 'has a host' do
      expect(described_class.new.host).to(eq('https://factchecktools.googleapis.com'))
    end

    it 'has a path' do
      expect(described_class.new.path).to(eq('/v1alpha1/claims:search'))
    end

    it 'parses a raw_claim' do
      raw = JSON.parse(File.read('spec/fixtures/google_fact_check_raw.json'))
      parsed_claim = described_class.new.parse_raw_claim(raw)
      expect(parsed_claim.class).to(eq(Hash))
      ClaimReview.mandatory_fields.each do |field|
        expect(Hashie::Mash[parsed_claim][field].nil?).to(eq(false))
      end
    end
  end
end
