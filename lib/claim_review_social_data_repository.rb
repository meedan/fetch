# frozen_string_literal: true

class ClaimReviewSocialDataRepository
  include Elasticsearch::Persistence::Repository
  include Elasticsearch::Persistence::Repository::DSL

  client Elasticsearch::Transport::Client.new(url: Settings.get('es_host'))
  index_name Settings.get_claim_review_social_data_es_index_name
  klass ClaimReviewSocialData

  settings number_of_shards: 1 do
    mapping do
      indexes :claim_review_id
      indexes :service, type: 'keyword'
    end
  end

  def self.init_index
    ClaimReviewSocialDataRepository.new.create_index!(force: true)
  end

  def self.safe_init_index
    if !ClaimReviewSocialData.client.indices.exists(index: Settings.get_claim_review_social_data_es_index_name)
      self.init_index
      return true
    end
    return false
  end
end
