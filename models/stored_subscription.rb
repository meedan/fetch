# frozen_string_literal: true

require_relative('../lib/elastic_search_accessors')
require_relative('../lib/elastic_search_methods')
class StoredSubscription
  include Elasticsearch::DSL
  include ElasticSearchAccessors
  extend ElasticSearchMethods
  def self.repository
    StoredSubscriptionRepository.new(client: client)
  end

  def self.es_index_name
    Settings.get_stored_subscription_es_index_name
  end

  def self.id_for_record(service, subscription_url)
    Digest::MD5.hexdigest("#{service}_#{subscription_url}")
  end

  def self.store_subscription(service, subscription_url, params={})
    repository.save(
      id: self.id_for_record(service, subscription_url),
      service: service,
      subscription_url: subscription_url,
      params: params.to_json
    )
  end

  def self.delete_subscription(service, url)
    document = self.get_subscription_for_url(service, url)
    repository.delete(id: self.id_for_record(document["service"], document["subscription_url"]))
  rescue => e
    return {} if e.class == Elasticsearch::Transport::Transport::Errors::NotFound
  end

  def self.get_subscriptions_for_service(service)
    ElasticSearchQuery.get_hits(
      StoredSubscription,
      body: ElasticSearchQuery.service_query(service)
    )
  end

  def self.get_subscription_for_url(service, url)
    ElasticSearchQuery.get_hits(
      StoredSubscription,
      body: ElasticSearchQuery.match_multiple_params([["service", service], ["subscription_url", url]])
    )[0] || {"params" => "{}"}
  end
end