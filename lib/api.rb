# frozen_string_literal: true

class API
  def self.pong
    {pong: true}
  end

  def self.claim_reviews(opts = {})
    opts[:per_page] ||= 20
    opts[:offset] ||= 0
    include_raw = opts[:include_raw] == "true" || opts[:include_raw].nil?
    opts.delete(:include_raw)
    return {error: "Offset is #{opts[:offset]}, and cannot be bigger than 10000. Query cannot execute"} if opts[:offset].to_i > 10000
    results = ClaimReview.search(
      opts,
      include_raw
    )
    if opts[:include_link_data]
      results = ClaimReview.enrich_claim_reviews_with_links(results)
    end
    return results
  end

  def self.about
    {
      live_urls: {
        "/about": About.about,
        "/claim_reviews": About.claim_reviews,
        "/services": About.services,
        "/subscribe": About.subscribe
      }
    }
  end

  def self.services
    {
      services: ClaimReviewParser.parsers.collect{|k,v| 
        {service: k, count: ClaimReview.get_count_for_service(k), earliest: ClaimReview.get_earliest_date_for_service(k), latest: ClaimReview.get_latest_date_for_service(k)}
      }
    }
  end

  def self.get_subscriptions(params)
    Subscription.get_subscriptions(params[:service])
  end

  def self.add_subscription(params)
    Subscription.add_subscription(params[:service], params[:url], params[:language])
    Subscription.get_subscriptions(params[:service])
  end

  def self.remove_subscription(params)
    Subscription.remove_subscription(params[:service], params[:url])
    Subscription.get_subscriptions(params[:service])
  end
end
