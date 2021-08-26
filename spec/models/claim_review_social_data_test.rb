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
  end
end