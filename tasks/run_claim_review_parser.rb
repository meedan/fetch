# frozen_string_literal: true

class RunClaimReviewParser
  include Sidekiq::Worker
  def perform(service, cursor_back_to_date = nil, overwrite_existing_claims=false)
    cursor_back_to_date = Time.parse(cursor_back_to_date) unless cursor_back_to_date.nil?
    ClaimReviewParser.record_service_heartbeat(service)
    ClaimReviewParser.run(service, cursor_back_to_date, overwrite_existing_claims)
    RunClaimReviewParser.perform_in(Settings.task_interevent_time, service)
  end

  def self.requeue(service)
    if $REDIS_CLIENT.get(ClaimReview.service_heartbeat_key(service)).nil?
      RunClaimReviewParser.perform_async(service)
      return true
    end
    false
  end
end
