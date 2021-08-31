# frozen_string_literal: true

require_relative('../lib/claim_review_export')
require_relative('../lib/elastic_search_accessors')
require_relative('../lib/elastic_search_methods')
class ClaimReviewSocialData
  include Elasticsearch::DSL
  include ElasticSearchAccessors
  extend ElasticSearchMethods
  def self.repository
    ClaimReviewSocialDataRepository.new(client: client)
  end

  def self.es_index_name
    Settings.get_claim_review_social_data_es_index_name
  end

  def self.id_for_record(parsed_claim_review, link)
    Digest::MD5.hexdigest("#{parsed_claim_review["service"]}_#{link}_#{parsed_claim_review["id"]}")
  end

  def self.store_link_for_parsed_claim_review(parsed_claim_review, link)
    pender_response = PenderClient.get_enrichment_for_url(link)
    pender_response["data"].delete("raw")
    pender_response["data"].delete("schema")
    repository.save(
      id: self.id_for_record(parsed_claim_review, link),
      link: link,
      claim_review_id: parsed_claim_review["id"],
      content: pender_response,
      service: parsed_claim_review["service"],
      claim_review_created_at: parsed_claim_review["created_at"]
    )
  end
end
