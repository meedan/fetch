# frozen_string_literal: true

require 'rspec'

# Assuming RunClaimReviewParser and related classes are already defined as provided

RSpec.describe RunClaimReviewParser do
  describe 'instance' do
    it 'walks through perform task' do
      allow(ClaimReviewParser).to receive(:run).with('foo', anything(), false, true).and_return(nil)
      allow(ClaimReviewParser).to receive(:parsers).and_return({
        "foo" => double(deprecated: false, interevent_time: 60 * 60)
      })
      allow(RunClaimReviewParser).to receive(:perform_in).with(60 * 60, 'foo').and_return(nil)
      expect(RunClaimReviewParser.new.perform('foo')).to(eq(nil))
    end
  end
  
  describe 'class' do
    describe '.requeue' do
      let(:service) { 'foo_bar' }

      context 'when heartbeat key for service is nil' do
        it 'requeues the job and returns true' do
          allow($REDIS_CLIENT).to receive(:get)
            .with(ClaimReview.service_heartbeat_key(service))
            .and_return(nil)
          expect(RunClaimReviewParser).to receive(:perform_async).with(service)
          expect(described_class.requeue(service)).to(eq(true))
        end
      end
    end

    describe '.not_enqueued_anywhere_else' do
      let(:service) { 'foo_bar' }

      before do
        # No need to clear Sidekiq sets since we're mocking them
      end

      context 'when no job with the service is enqueued and no Redis key is set' do
        it 'returns true' do
          # Mock RetrySet, ScheduledSet, and Queue to have no matching jobs
          retry_set = instance_double(Sidekiq::RetrySet)
          scheduled_set = instance_double(Sidekiq::ScheduledSet)
          queue = instance_double(Sidekiq::Queue)

          allow(Sidekiq::RetrySet).to receive(:new).and_return(retry_set)
          allow(Sidekiq::ScheduledSet).to receive(:new).and_return(scheduled_set)
          allow(Sidekiq::Queue).to receive(:new).and_return(queue)

          allow(retry_set).to receive(:each).and_return([])
          allow(scheduled_set).to receive(:each).and_return([])
          allow(queue).to receive(:each).and_return([])

          expect(described_class.should_requeue(service)).to(eq(true))
        end
      end

      context 'when no job with the service is enqueued' do
        it 'returns true' do
          # Mock RetrySet, ScheduledSet, and Queue to have no matching jobs
          retry_set = instance_double(Sidekiq::RetrySet)
          scheduled_set = instance_double(Sidekiq::ScheduledSet)
          queue = instance_double(Sidekiq::Queue)

          allow(Sidekiq::RetrySet).to receive(:new).and_return(retry_set)
          allow(Sidekiq::ScheduledSet).to receive(:new).and_return(scheduled_set)
          allow(Sidekiq::Queue).to receive(:new).and_return(queue)

          allow(retry_set).to receive(:each).and_return([])
          allow(scheduled_set).to receive(:each).and_return([])
          allow(queue).to receive(:each).and_return([])

          expect(described_class.not_enqueued_anywhere_else(service)).to(eq(true))
        end
      end

      context 'when a job with the service is in the RetrySet but is not in Redis' do
        it 'returns true' do
          # Mock a matching job in RetrySet
          matching_job = double('RunClaimReviewParser', item: { "args" => [service.to_s] })
          retry_set = instance_double(Sidekiq::RetrySet)

          allow(Sidekiq::RetrySet).to receive(:new).and_return(retry_set)
          allow(retry_set).to receive(:each).and_yield(matching_job)

          # Ensure ScheduledSet and Queue do not yield any jobs
          scheduled_set = instance_double(Sidekiq::ScheduledSet)
          queue = instance_double(Sidekiq::Queue)
          allow(Sidekiq::ScheduledSet).to receive(:new).and_return(scheduled_set)
          allow(Sidekiq::Queue).to receive(:new).and_return(queue)
          allow(scheduled_set).to receive(:each).and_return([])
          allow(queue).to receive(:each).and_return([])

          expect(described_class.not_enqueued_anywhere_else(service)).to(eq(true))
        end
      end

      context 'when a job with the service is in the ScheduledSet but is not in Redis' do
        it 'returns true' do
          # Mock a matching job in ScheduledSet
          matching_job = double('RunClaimReviewParser', item: { "args" => [service.to_s] })
          scheduled_set = instance_double(Sidekiq::ScheduledSet)

          allow(Sidekiq::ScheduledSet).to receive(:new).and_return(scheduled_set)
          allow(scheduled_set).to receive(:each).and_yield(matching_job)

          # Ensure RetrySet and Queue do not yield any jobs
          retry_set = instance_double(Sidekiq::RetrySet)
          queue = instance_double(Sidekiq::Queue)
          allow(Sidekiq::RetrySet).to receive(:new).and_return(retry_set)
          allow(Sidekiq::Queue).to receive(:new).and_return(queue)
          allow(retry_set).to receive(:each).and_return([])
          allow(queue).to receive(:each).and_return([])

          expect(described_class.not_enqueued_anywhere_else(service)).to(eq(true))
        end
      end

      context 'when a job with the service is in the Queue but is not in Redis' do
        it 'returns true' do
          # Mock a matching job in Queue
          matching_job = double('RunClaimReviewParser', item: { "args" => [service.to_s] })
          queue = instance_double(Sidekiq::Queue)

          allow(Sidekiq::Queue).to receive(:new).and_return(queue)
          allow(queue).to receive(:each).and_yield(matching_job)

          # Ensure RetrySet and ScheduledSet do not yield any jobs
          retry_set = instance_double(Sidekiq::RetrySet)
          scheduled_set = instance_double(Sidekiq::ScheduledSet)
          allow(Sidekiq::RetrySet).to receive(:new).and_return(retry_set)
          allow(Sidekiq::ScheduledSet).to receive(:new).and_return(scheduled_set)
          allow(retry_set).to receive(:each).and_return([])
          allow(scheduled_set).to receive(:each).and_return([])

          expect(described_class.not_enqueued_anywhere_else(service)).to(eq(true))
        end
      end

      context 'when a job with the service is in the RetrySet and is in Redis' do
        it 'returns true' do
          allow($REDIS_CLIENT).to receive(:get)
            .with(ClaimReview.service_heartbeat_key(service))
            .and_return("test")
          # Mock a matching job in RetrySet
          matching_job = double('RunClaimReviewParser', item: { "args" => [service.to_s] })
          retry_set = instance_double(Sidekiq::RetrySet)

          allow(Sidekiq::RetrySet).to receive(:new).and_return(retry_set)
          allow(retry_set).to receive(:each).and_yield(matching_job)

          # Ensure ScheduledSet and Queue do not yield any jobs
          scheduled_set = instance_double(Sidekiq::ScheduledSet)
          queue = instance_double(Sidekiq::Queue)
          allow(Sidekiq::ScheduledSet).to receive(:new).and_return(scheduled_set)
          allow(Sidekiq::Queue).to receive(:new).and_return(queue)
          allow(scheduled_set).to receive(:each).and_return([])
          allow(queue).to receive(:each).and_return([])

          expect(described_class.should_requeue(service)).to(eq(true))
        end
      end

      context 'when a job with the service is in the ScheduledSet and is in Redis' do
        it 'returns true' do
          allow($REDIS_CLIENT).to receive(:get)
            .with(ClaimReview.service_heartbeat_key(service))
            .and_return("test")
          # Mock a matching job in ScheduledSet
          matching_job = double('RunClaimReviewParser', item: { "args" => [service.to_s] })
          scheduled_set = instance_double(Sidekiq::ScheduledSet)

          allow(Sidekiq::ScheduledSet).to receive(:new).and_return(scheduled_set)
          allow(scheduled_set).to receive(:each).and_yield(matching_job)

          # Ensure RetrySet and Queue do not yield any jobs
          retry_set = instance_double(Sidekiq::RetrySet)
          queue = instance_double(Sidekiq::Queue)
          allow(Sidekiq::RetrySet).to receive(:new).and_return(retry_set)
          allow(Sidekiq::Queue).to receive(:new).and_return(queue)
          allow(retry_set).to receive(:each).and_return([])
          allow(queue).to receive(:each).and_return([])

          expect(described_class.should_requeue(service)).to(eq(true))
        end
      end

      context 'when a job with the service is in the Queue and is in Redis' do
        it 'returns true' do
          allow($REDIS_CLIENT).to receive(:get)
            .with(ClaimReview.service_heartbeat_key(service))
            .and_return("test")
          # Mock a matching job in Queue
          matching_job = double('RunClaimReviewParser', item: { "args" => [service.to_s] })
          queue = instance_double(Sidekiq::Queue)

          allow(Sidekiq::Queue).to receive(:new).and_return(queue)
          allow(queue).to receive(:each).and_yield(matching_job)

          # Ensure RetrySet and ScheduledSet do not yield any jobs
          retry_set = instance_double(Sidekiq::RetrySet)
          scheduled_set = instance_double(Sidekiq::ScheduledSet)
          allow(Sidekiq::RetrySet).to receive(:new).and_return(retry_set)
          allow(Sidekiq::ScheduledSet).to receive(:new).and_return(scheduled_set)
          allow(retry_set).to receive(:each).and_return([])
          allow(scheduled_set).to receive(:each).and_return([])

          expect(described_class.should_requeue(service)).to(eq(true))
        end
      end
    end
  end
end
