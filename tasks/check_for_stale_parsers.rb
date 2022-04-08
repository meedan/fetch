class CheckForStaleParsers
  include Sidekiq::Worker
  def perform
    enabled_services = ClaimReviewParser.enabled_subclasses.collect(&:service).collect(&:to_s)
    stale_parsers = []
    API.services[:services].each do |service_stats|
      next if !enabled_services.include?(service_stats[:service])
      if service_stats[:latest].nil? || (Time.now-Time.parse(service_stats[:latest])) > 60*60*24*7
        Error.log("Parser '#{service_stats[:service]}' has fallen behind! Last data observed: #{service_stats[:latest].inspect}")
        stale_parsers << service_stats[:service]
      end
    end
    stale_parsers
  end
end