# frozen_string_literal: true

describe NewtralFactCheck do
  describe 'instance' do
    it 'has a hostname' do
      expect(described_class.new.hostname).to(eq('https://www.newtral.es'))
    end

    it 'has a fact_list_path' do
      expect(described_class.new.fact_list_path(1)).to(eq("/wp-json/nwtfmg/v1/claim-reviews?page=1&posts_per_page=15&firstDate=2018-01-01&lastDate=#{Time.now.strftime("%Y-%m-%d")}"))
    end

    it 'extracts a url' do
      expect(described_class.new.url_extractor({"data" => [{"url" => "blah"}]})).to(eq(["blah"]))
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
