# frozen_string_literal: true

class GetClaims
  include Sidekiq::Worker
  def perform(service)
    ReviewParser.run(service)
  end
end
