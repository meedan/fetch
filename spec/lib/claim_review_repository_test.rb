# frozen_string_literal: true

describe ClaimReviewRepository do
  describe 'class' do
    it 'expects setting number of shards' do
      expect(described_class.settings.settings).to(eq({ number_of_shards: 1 }))
    end

    it 'expects index_name' do
      expect(described_class.index_name).to(eq('claim_reviews'))
    end

    it 'expects document_type' do
      expect(described_class.document_type).to(eq('claim_review'))
    end

    it 'expects klass' do
      expect(described_class.klass).to(eq(ClaimReview))
    end
  end
end
