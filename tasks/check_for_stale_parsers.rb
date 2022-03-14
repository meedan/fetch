class CheckForStaleParsers
  include Sidekiq::Worker
  def perform
    stale_parsers = []
    API.services[:services].each do |service_stats|
      if service_stats[:latest].nil? || (Time.now-Time.parse(service_stats[:latest])) > 60*60*24*7
        Error.log("Parser '#{service_stats[:service]}' has fallen behind! Last data observed: #{service_stats[:latest].inspect}")
        stale_parsers << service_stats[:service]
      end
    end
    stale_parsers
  end
end