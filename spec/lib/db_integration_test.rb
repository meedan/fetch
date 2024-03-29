SimpleCov.command_name "test:integration"
$storage_results = {}
$subscription_storage_results = {}
$subclasses = ClaimReviewParser.enabled_subclasses.reject{|x| x.service.to_s.include?("#")}
def generate_test_data(subclass)
  return nil if $subscription_storage_results[subclass]
  url = "http://test.com/link"
  params = {"foo" => "bar"}
  store_response = StoredSubscription.store_subscription(subclass.service, url, params)
  StoredSubscription.repository.refresh_index!
  get_response = Subscription.get_subscriptions(subclass.service)
  StoredSubscription.repository.refresh_index!
  delete_response = StoredSubscription.delete_subscription(subclass.service, url)
  StoredSubscription.repository.refresh_index!
  $subscription_storage_results[subclass] = {}
  $subscription_storage_results[subclass][:store] = store_response
  $subscription_storage_results[subclass][:get] = get_response
  $subscription_storage_results[subclass][:delete] = delete_response
  raw = JSON.parse(File.read("spec/fixtures/#{subclass.service}_raw.json"))
  raw['page'] = Nokogiri.parse(raw['page']) if raw['page']
  parsed_claim_review = subclass.new.parse_raw_claim_review(raw)
  $storage_results[subclass] = subclass.new("2000-01-01", true).process_claim_reviews([parsed_claim_review])
end

describe 'integration test with ElasticSearch' do#, integration: true do
  include Rack::Test::Methods

  def app
    Site
  end

  before do
    WebMock.allow_net_connect!
    Mafindo.any_instance.stub(:get_authors).and_return([{"id" => 36, "nama"=>"blah", "website"=>"blah"}])
    AlegreClient.stub(:get_enrichment_for_url).with(anything).and_return({"text" => "blah", "links" => ["http://example.com"]})
    PenderClient.stub(:get_enrichment_for_url).with(anything).and_return(JSON.parse(File.read("spec/fixtures/pender_response.json")))
    ClaimReviewParser.enabled_subclasses.reject{|x| x.service.to_s.include?("#")}.each do |subclass|
      generate_test_data(subclass)
    end
    AlegreClient.unstub(:get_enrichment_for_url)
    PenderClient.unstub(:get_enrichment_for_url)
  end

  after do
    WebMock.disable_net_connect!
  end

  context "for each subclass" do
    $subclasses.each do |subclass|
      it "gets subscriptons" do
        url = "http://test.com/link"
        params = {"foo" => "bar"}
        expect($subscription_storage_results[subclass][:get]).to(eq({subclass.service=>{url=>params}}))
      end

      it "creates a subscripton" do
        expect($subscription_storage_results[subclass][:delete].class).to(eq(Hash))
        expect($subscription_storage_results[subclass][:delete].keys.sort).to(eq(["_id", "_index", "_primary_term", "_seq_no", "_shards", "_type", "_version", "result"]))
      end

      it "deletes a subscription" do
        expect($subscription_storage_results[subclass][:delete].class).to(eq(Hash))
        expect($subscription_storage_results[subclass][:delete].keys.sort).to(eq(["_id", "_index", "_primary_term", "_seq_no", "_shards", "_type", "_version", "result"]))
      end

      it "ensures response looks as if it were saved" do
        expect($storage_results[subclass].class).to(eq(Array))
        expect($storage_results[subclass][0].class).to(eq(Hash))
      end

      it "ensures response has the mandatory fields" do
        expect($storage_results[subclass].first.values_at(*($storage_results[subclass].first.keys-[:raw_claim_review])).collect(&:class).uniq-[NilClass, String, Float, Time, Integer]).to(eq([]))
      end

      it "ensures access via ClaimReview#existing_ids" do
        ids = $storage_results[subclass].collect{|x| x[:id]}
        expect(ClaimReview.existing_ids(ids, subclass.service).class).to(eq(Array))
        expect(ClaimReview.existing_ids(ids, subclass.service).count).to(eq(1))
      end

      it "ensures access via ClaimReview#existing_urls" do
        urls = $storage_results[subclass].collect{|x| x[:claim_review_url]}
        expect(ClaimReview.existing_urls(urls, subclass.service).class).to(eq(Array))
        expect(ClaimReview.existing_urls(urls, subclass.service).count).to(eq(1))
      end

      it "ensures count via ClaimReview#get_count_for_service" do
        expect(ClaimReview.get_count_for_service(subclass.service) > 0).to(eq(true))
      end

      it "ensures access via Site-layer" do
        response = get "/claim_reviews", "service=#{subclass.service}"
        expect(JSON.parse(response.body)[0]["url"]).to(eq($storage_results[subclass][0][:claim_review_url]))
      end

      it "ensures access via API-layer" do
        expect(API.claim_reviews(service: subclass.service.to_s)[0][:url]).to(eq($storage_results[subclass][0][:claim_review_url]))
      end

      it "ensures access via Search-layer" do
        expect(ClaimReview.search(service: subclass.service.to_s)[0][:url]).to(eq($storage_results[subclass][0][:claim_review_url]))
      end

      it "ensures access via Search-layer" do
        language = Language.get_reliable_language($storage_results[subclass][0][:claim_review_headline])
        if language
          expect(ClaimReview.search(language: language)[0][:inLanguage]).to(eq(language))
        end
      end

      it "ensures deletion of object" do
        response = ClaimReview.delete_by_service(subclass.service.to_s)
        expect(response["failures"]).to(eq([]))
      end
    end
  end
end
