# frozen_string_literal: true

describe StoredSubscription do
  describe 'instance' do
    it 'responds to to_hash' do
      expect(StoredSubscription.new({}).to_hash).to(eq({}))
    end
  end
  describe 'class' do
    it 'expects to rescue failed storage' do
      StoredSubscriptionRepository.any_instance.stub(:delete).with(anything).and_raise(Elasticsearch::Transport::Transport::Errors::NotFound.new({}))
      expect(StoredSubscription.delete_subscription("service", "url")).to(eq({}))
    end
    it 'expects repository instance' do
      expect(described_class.repository.class).to(eq(StoredSubscriptionRepository))
    end

    it 'expects es_index_name' do
      expect(described_class.es_index_name).to(eq(Settings.get_stored_subscription_es_index_name))
    end
  end
end