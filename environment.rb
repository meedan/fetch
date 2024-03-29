# frozen_string_literal: true

require('cgi')
require('date')
require('time')
require('csv')
require('json')
require('logger')
require('delegate')
require('rack')
require('digest')
require('airbrake')
require('faraday')
require('sinatra')
require('pry')
require('sidekiq')
require('sidekiq/cron')
require('hashie')
require('nokogiri')
require('cld')
require('parallel')
require('dgaff')
require('restclient')
require('fuzzystringmatch')
require('matrix')
require('tf-idf-similarity')
require('elasticsearch')
require('elasticsearch/dsl')
require('elasticsearch/persistence')
require('retriable')
require('aws-sdk-s3')

require_relative('lib/settings')
Settings.check_into_elasticsearch
ENV['env'] ||= 'local'
ENV['APP_ENV'] ||= ENV['env']
REDIS_URL = {url: Settings.redis_url}
$REDIS_CLIENT = Redis.new(REDIS_URL)
$REDIS_CLIENT.auth(Settings.get('redis_password')) if Settings.get('redis_password')
redis_config = proc { |config|
  if Settings.get('redis_password')
    config.redis = REDIS_URL.merge(password: Settings.get('redis_password'))
  else
    config.redis = REDIS_URL
  end
}
Sidekiq.configure_client do |config|
  redis_config.call(config)
end
Sidekiq.configure_server do |config|
  redis_config.call(config)
end
unless Settings.blank?('airbrake_api_host')
  Airbrake.configure do |config|
    config.host = Settings.get('airbrake_api_host')
    config.project_id = 1 # required, but any positive integer works
    config.project_key = Settings.get('airbrake_api_key')
    config.logger.level = Logger::DEBUG
  end
end
Dir[File.dirname(__FILE__) + '/extensions/*.rb'].sort.each { |file| require file }
Dir[File.dirname(__FILE__) + '/models/*.rb'].sort.each { |file| require file }
Dir[File.dirname(__FILE__) + '/lib/*.rb'].sort.each { |file| require file }
Dir[File.dirname(__FILE__) + '/tasks/*.rb'].sort.each { |file| require file }
Dir[File.dirname(__FILE__) + '/lib/claim_review_parsers/*.rb'].sort.each { |file| require file }
