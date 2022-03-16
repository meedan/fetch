# frozen_string_literal: true

describe ClaimReviewSocialData do
  describe 'instance' do
    it 'responds to to_hash' do
      expect(ClaimReviewSocialData.new({}).to_hash).to(eq({}))
    end
  end
  describe 'class' do
    it 'expects repository instance' do
      expect(described_class.repository.class).to(eq(ClaimReviewSocialDataRepository))
    end

    it 'expects es_index_name' do
      expect(described_class.es_index_name).to(eq(Settings.get_claim_review_social_data_es_index_name))
    end

    it 'expects es_index_name' do
      PenderClient.stub(:get_enrichment_for_url).with(anything).and_return({foo: "bar"})
      ClaimReviewSocialDataRepository.any_instance.stub(:save).with(anything).and_raise(StandardError)
      expect(described_class.store_link_for_parsed_claim_review({"wow": "A claim review"}, "http://and.wow/link")).to(eq(false))
    end
  end
end