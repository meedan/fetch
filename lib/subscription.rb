class Subscription
  def self.keyname(service)
    "claim_review_webhooks_#{service}"
  end

  def self.url_params_key(url)
    Digest::MD5.hexdigest(url)+"_params"
  end

  def self.get_existing_params_for_url(service, url)
    StoredSubscription.get_subscription_for_url(service, url)['params']
  end

  def self.add_subscription(services, urls, languages=nil)
    languages = [languages].flatten.compact
    [services].flatten.collect do |service|
      [urls].flatten.collect do |url|
        existing_params = self.get_existing_params_for_url(service, url)
        existing_params["language"] ||= []
        languages.each do |language|
          existing_params["language"] << language
        end
        StoredSubscription.store_subscription(service, url, existing_params)
      end
    end.flatten
  end
  
  def self.remove_subscription(services, urls)
    [services].flatten.collect do |service|
      [urls].flatten.collect do |url|
        StoredSubscription.delete_subscription(service, url)
      end
    end.flatten
  end

  def self.get_subscriptions(services)
    Hash[[services].flatten.collect do |service|
      webhooks = StoredSubscription.get_subscriptions_for_service(service)
      [service, Hash[webhooks.collect{|url| [url, self.get_existing_params_for_url(service, url)]}]]
    end]
  end

  def self.claim_review_can_be_sent(webhook_url, webhook_params, claim_review)
    webhook_params ||= {}
    no_language_restriction = webhook_params["language"].nil? || webhook_params["language"].empty?
    language_matches = (webhook_params["language"] && webhook_params["language"].include?(claim_review[:inLanguage]))
    return no_language_restriction || language_matches
  end

  def self.send_webhook_notification(webhook_url, webhook_params, claim_review)
    if self.claim_review_can_be_sent(webhook_url, webhook_params, claim_review)
      RestClient.post(webhook_url, {claim_review: claim_review})
    end
  end

  def self.safe_send_webhook_notification(webhook_url, webhook_params, claim_review, raise_error=true)
    begin
      self.send_webhook_notification(webhook_url, webhook_params, claim_review)
    rescue => e
      Error.log(e, {}, raise_error)
    end
  end

  def self.notify_subscribers(services, claim_review)
    self.get_subscriptions(services).values.each do |subscription|
      subscription.each do |webhook_url, webhook_params|
        self.safe_send_webhook_notification(webhook_url, webhook_params, claim_review)
      end
    end
  end
end