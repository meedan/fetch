# frozen_string_literal: true

describe DataCommons do
  describe 'instance' do
    it 'parses a raw_claim_review' do
      raw = JSON.parse(File.read('spec/fixtures/data_commons_raw.json'))
      parsed_claim = described_class.new.parse_raw_claim_review(raw)
      expect(parsed_claim.class).to(eq(Hash))
      ClaimReview.mandatory_fields.each do |field|
        expect(QuietHashie[parsed_claim][field].nil?).to(eq(false))
      end
    end

    it 'parses the in-repo dataset' do
      ClaimReviewSocialDataRepository.any_instance.stub(:save).with(anything).and_return({ _index: Settings.get('es_index_name_cr_social_data'), _type: Settings.get('es_index_name_cr_social_data'), _id: 'vhV84XIBOGf2XeyOAD12', _version: 1, result: 'created', _shards: { total: 2, successful: 1, failed: 0 }, _seq_no: 130_821, _primary_term: 2 })
      PenderClient.stub(:get_enrichment_for_url).with(anything).and_return(JSON.parse(File.read("spec/fixtures/pender_response.json")))
      AlegreClient.stub(:get_enrichment_for_url).with(anything).and_return({"text" => "blah", "links" => ["http://example.com"]})
      single_case = JSON.parse(File.read('spec/fixtures/data_commons_raw.json'))
      File.stub(:read).with(described_class.dataset_path).and_return({ 'dataFeedElement' => [single_case] }.to_json)
      File.stub(:read).with("config/cookies.json").and_return({}.to_json)
      ClaimReview.stub(:existing_ids).with([single_case['item'][0]['url']], described_class.service).and_return([])
      ClaimReview.stub(:existing_urls).with([single_case['item'][0]['url']], described_class.service).and_return([])
      ClaimReviewRepository.any_instance.stub(:save).with(anything).and_return({ _index: 'claim_reviews', _type: 'claim_review', _id: 'vhV84XIBOGf2XeyOAD12', _version: 1, result: 'created', _shards: { total: 2, successful: 1, failed: 0 }, _seq_no: 130_821, _primary_term: 2 })
      expect(described_class.new.get_claim_reviews).to(eq(nil))
    end
    it 'ensures string from author_link_from_raw_claim_review' do
      expect(described_class.new.author_link_from_raw_claim_review({'item' => [{'author' => {'url' => 'blah'}}]})).to(eq('blah'))
    end

    it 'parses non-floatable claim_result_score_from_raw_claim_review' do
      expect(described_class.new.claim_result_score_from_raw_claim_review({ 'reviewRating' => { 'bestRating' => "blah", 'worstRating' => "goober", 'ratingValue' => "true" } })).to(eq(nil))
    end

    it 'parses non-empty claim_result_score_from_raw_claim_review' do
      expect(described_class.new.claim_result_score_from_raw_claim_review({ 'reviewRating' => { 'bestRating' => 10, 'worstRating' => 0, 'ratingValue' => 5 } })).to(eq(0.5))
    end

    it 'parses partially-empty claim_result_score_from_raw_claim_review' do
      expect(described_class.new.claim_result_score_from_raw_claim_review({ 'reviewRating' => { 'ratingValue' => 5 } })).to(eq(5))
    end

    it 'rescues from id_from_raw_claim_review' do
      expect(described_class.new.id_from_raw_claim_review({})).to(eq(''))
    end

    it 'rescues from claim_result_from_raw_claim_review' do
      expect(described_class.new.claim_result_from_raw_claim_review(nil)).to(eq(nil))
    end
    it 'rescues from author_from_raw_claim_review' do
      expect(described_class.new.author_from_raw_claim_review({})).to(eq(nil))
    end

    it 'rescues from created_at_from_raw_claim_review' do
      expect(described_class.new.created_at_from_raw_claim_review({})).to(eq(nil))
    end

    it 'rescues from author_from_raw_claim_review' do
      expect(described_class.new.author_from_raw_claim_review({})).to(eq(nil))
    end

    it 'rescues from author_link_from_raw_claim_review' do
      expect(described_class.new.author_link_from_raw_claim_review(nil)).to(eq(nil))
    end

    it 'rescues from claim_headline_from_raw_claim_review' do
      expect(described_class.new.claim_headline_from_raw_claim_review(1)).to(eq(nil))
    end

    it 'rescues from claim_result_from_raw_claim_review' do
      expect(described_class.new.claim_result_from_raw_claim_review(1)).to(eq(nil))
    end

    it 'returns nil from claim_url_from_raw_claim_review' do
      expect(described_class.new.claim_url_from_raw_claim_review({})).to(eq(nil))
    end

    it 'rescues from claim_url_from_raw_claim_review' do
      expect(described_class.new.claim_url_from_raw_claim_review(nil)).to(eq(nil))
    end
  end
end
