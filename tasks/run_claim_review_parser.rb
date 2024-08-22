# frozen_string_literal: true

require 'timeout'

class RunClaimReviewParser
  include Sidekiq::Worker

  MAX_RUNTIME = 60 * 60 # 1 hour in seconds

  def perform(service, cursor_back_to_date = nil, overwrite_existing_claims=false, send_notifications=true)
    cursor_back_to_date = Time.parse(cursor_back_to_date) unless cursor_back_to_date.nil?
    ClaimReviewParser.record_service_heartbeat(service)

    begin
      Timeout.timeout(MAX_RUNTIME) do
        ClaimReviewParser.run(service, cursor_back_to_date, overwrite_existing_claims, send_notifications)
      end
    rescue Timeout::Error
      # Handle timeout - log the error, send notification, requeue, etc.
      handle_timeout(service)
    ensure
      # Requeue the job if the parser is not deprecated
      if !ClaimReviewParser.parsers[service].deprecated
        RunClaimReviewParser.perform_in(ClaimReviewParser.parsers[service].interevent_time, service)
      end
    end
  end

  def self.requeue(service)
    if $REDIS_CLIENT.get(ClaimReview.service_heartbeat_key(service)).nil?
      RunClaimReviewParser.perform_async(service)
      return true
    end
    false
  end

  private

  def handle_timeout(service)
    # Log the timeout occurrence
    logger.error("Timeout reached for #{service} in RunClaimReviewParser")
    # Additional actions like sending notifications can be added here
    # Optionally requeue the job immediately
    RunClaimReviewParser.requeue(service)
  end
end
