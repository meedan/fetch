# frozen_string_literal: true

class StoredSubscriptionRepository
  include Elasticsearch::Persistence::Repository
  include Elasticsearch::Persistence::Repository::DSL

  client Elasticsearch::Client.new(url: Settings.get('es_host'))
  index_name Settings.get_stored_subscription_es_index_name
  klass StoredSubscription

  settings number_of_shards: 1 do
    mapping do
      indexes :service, type: 'keyword'
    end
  end

  def self.init_index
    StoredSubscriptionRepository.new.create_index!(force: true)
  end

  def self.safe_init_index
    if !StoredSubscription.client.indices.exists(index: Settings.get_stored_subscription_es_index_name)
      self.init_index
      return true
    end
    return false
  end
end
