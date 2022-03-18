# frozen_string_literal: true

describe AfricaCheck do
  describe 'instance' do
    it 'has a hostname' do
      expect(described_class.new.hostname).to(eq('https://africacheck.org'))
    end

    it 'rescues against a claim_review_image_url_from_raw_claim_review' do
      expect(described_class.new.claim_review_image_url_from_raw_claim_review({"page" => Nokogiri.parse("<article about='/blah'>wow</article>")})).to(eq(nil))
    end

    it 'expects a claim_result_text_map' do
      expect(described_class.new.rating_map.class).to(eq(Hash))
    end

    it 'stubs the response for a nil get_claim_review_from_raw_claim_review' do
      expect(described_class.new.parse_raw_claim_review({"url" => "blah"})).to(eq({id: "blah"}))
    end

    it 'checks that get_new_fact_page_urls(page) works' do
      RestClient::Request.stub(:execute).with(anything).and_return(JSON.parse(File.read('spec/fixtures/africa_check_page_response.json')).to_json)
      described_class.any_instance.stub(:get_existing_urls).with(anything).and_return([])
      response = described_class.new.get_new_fact_page_urls(1)
      expect(response.class).to(eq(Array))
      expect(response.empty?).to(eq(false))
    end

    it 'parses a raw_claim_review' do
      raw = JSON.parse(File.read('spec/fixtures/africa_check_raw.json'))
      raw['page'] = Nokogiri.parse(raw['page'])
      parsed_claim = described_class.new.parse_raw_claim_review(raw)
      expect(parsed_claim.class).to(eq(Hash))
      ClaimReview.mandatory_fields.each do |field|
        expect(QuietHashie[parsed_claim][field].nil?).to(eq(false))
      end
    end
  end
end
