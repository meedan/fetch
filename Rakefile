# frozen_string_literal: true

require('rake')
require('rspec/core/rake_task')
load('environment.rb')

desc "Run all tasks"
task :test do
  Rake::Task['test:unit'].execute
  Rake::Task['test:integration'].execute    
end

namespace :test do
  RSpec::Core::RakeTask.new(:unit) do |t|
    t.pattern = Dir.glob('spec/**/*_test.rb').reject{|t| t.include?("_integration_test.rb")}
  end
  RSpec::Core::RakeTask.new(:integration) do |t|
    t.pattern = Dir.glob('spec/**/*_test.rb').select{|t| t.include?("_integration_test.rb")}
  end
end

task :init_index do
  puts "ElasticSearch host is #{Settings.get('es_host')} and index is #{Settings.get('es_index_name')}"
  puts "Creating index..."
  ClaimReviewRepository.new.create_index!(force: true)
  puts "Trying to find index..."
  puts %x[curl #{Settings.get('es_host')}/#{Settings.get('es_index_name')}]
end

task :schedule_stale_parser_check do
  Sidekiq::Cron::Job.create(name: 'Stale Parser Check', cron: '0 0 * * *', class: 'CheckForStaleParsers')
end

task :list_datasources do
  puts ClaimReviewParser.subclasses.map(&:service)
end

task :collect_datasource do
  ARGV.each do |a|
    task a.to_sym do
    end
  end
  datasource = ARGV[1]
  cursor_back_to_date = ARGV[2]
  overwrite_existing_claims = ARGV[3] == "true"
  RunClaimReviewParser.perform_async(datasource, cursor_back_to_date, overwrite_existing_claims)
end

task :collect_all do
  ARGV.each do |a|
    task a.to_sym do
    end
  end
  cursor_back_to_date = ARGV[1]
  overwrite_existing_claims = ARGV[2] == "true"
  ClaimReviewParser.enabled_subclasses.map(&:service).each do |datasource|
    puts "Updating #{datasource}..."
    RunClaimReviewParser.perform_async(datasource, cursor_back_to_date, overwrite_existing_claims)
  end
end

task :init_index do
  ClaimReviewRepository.init_index
  ClaimReviewSocialDataRepository.init_index
  StoredSubscriptionRepository.init_index
end

task :safe_init_index do
  ClaimReviewRepository.safe_init_index
  ClaimReviewSocialDataRepository.safe_init_index
  StoredSubscriptionRepository.safe_init_index
end

task :requeue do
  ClaimReviewParser.enabled_subclasses.map(&:service).each do |datasource|
    puts "Resetting crawls for #{datasource}..."
    result = RunClaimReviewParser.requeue(datasource)
    if result
      puts "Update for #{datasource} is queued."
    else
      puts "Update for #{datasource} failed to queue, already queued."
    end
    ClaimReviewParser.record_service_heartbeat(datasource)
  end
end
task(default: [:test])
