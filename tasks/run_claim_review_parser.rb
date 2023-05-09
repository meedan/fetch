# frozen_string_literal: true

class RunClaimReviewParser
  include Sidekiq::Worker
  def perform(service, cursor_back_to_date = nil, overwrite_existing_claims=false, send_notifications=true)
    cursor_back_to_date = Time.parse(cursor_back_to_date) unless cursor_back_to_date.nil?
    ClaimReviewParser.record_service_heartbeat(service)
    
    ClaimReviewParser.run(service, cursor_back_to_date, overwrite_existing_claims, send_notifications)
    RunClaimReviewParser.perform_in(ClaimReviewParser.parsers[service].interevent_time, service) if !ClaimReviewParser.parsers[service].deprecated
  end

  def self.requeue(service)
    if $REDIS_CLIENT.get(ClaimReview.service_heartbeat_key(service)).nil?
      RunClaimReviewParser.perform_async(service)
      return true
    end
    false
  end
end
