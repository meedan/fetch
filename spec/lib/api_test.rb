# frozen_string_literal: true

describe API do
  describe 'class' do
    it 'has a load balancer endpoint' do
      expect(described_class.pong).to(eq({pong: true}))
    end

    it 'has a claim review endpoint' do
      ClaimReview.stub(:search).with({:offset=>0, :per_page=>20}, true).and_return([])
      expect(described_class.claim_reviews({})).to(eq([]))
    end

    it 'has a nonempty claim review endpoint' do
      ClaimReview.stub(:search).with({:offset=>0, :per_page=>20}, true).and_return([{ bloop: 1 }])
      expect(described_class.claim_reviews({})).to(eq([{ bloop: 1 }]))
    end

    it 'has an about page' do
      expect(described_class.about.class).to(eq(Hash))
    end

    it 'lists available services' do
      Elasticsearch::Client.any_instance.stub(:search).with(anything()).and_return({"took"=>21, "timed_out"=>false, "_shards"=>{"total"=>1, "successful"=>1, "skipped"=>0, "failed"=>0}, "hits"=>{"total"=>14055, "max_score"=>2.1063054, "hits"=>[{"_source" => {"created_at" => "2020-01-01", "_index"=>"claim_reviews", "_type"=>"claim_review", "id"=>"0f6a429f5a4e6d017b152665f9cdcadc"}}]}})
      expect(described_class.services.class).to(eq(Hash))
    end

    it 'lists subscriptions for a service' do
      Subscription.stub(:get_subscriptions).with('blah').and_return(['http://blah.com/respond'])
      expect(described_class.get_subscriptions(service: 'blah')).to(eq(['http://blah.com/respond']))
    end

    it 'adds subscriptions for a service' do
      Elasticsearch::Client.any_instance.stub(:search).with(anything).and_return({ 'hits' => { 'hits' => [{ '_source' => {"id"=>"4471b889d47383cb6c4cff244e31739e", "service"=>"tempo_cekfakta", "subscription_url"=>"http://blah.com/respond", "params"=>{"language"=>[]}.to_json} }, { '_source' => {"id"=>"4471b889d47383cb6c4cff244e31739e", "service"=>"tempo_cekfakta", "subscription_url"=>"http://blah.com/respond2", "params"=>{"language"=>[]}.to_json} }] } })
      Subscription.stub(:get_subscriptions).with('blah').and_return(['http://blah.com/respond'])
      StoredSubscription.stub(:store_subscription).with("blah", 'http://blah.com/respond', {"language" => []}).and_return({ _index: Settings.get('es_index_name_stored_subscription'), _type: Settings.get('es_index_name_stored_subscription'), _id: 'vhV84XIBOGf2XeyOAD12', _version: 1, result: 'created', _shards: { total: 2, successful: 1, failed: 0 }, _seq_no: 130_821, _primary_term: 2 })
      expect(described_class.add_subscription(service: 'blah', url: 'http://blah.com/respond')).to(eq(['http://blah.com/respond']))
    end

    it 'removes subscriptions for a service' do
      Subscription.stub(:get_subscriptions).with('blah').and_return(['http://blah.com/respond'])
      StoredSubscription.stub(:delete_subscription).with("blah", 'http://blah.com/respond').and_return({"_index"=>Settings.get('es_index_name_stored_subscription'), "_type"=>"_doc", "_id"=>"4471b889d47383cb6c4cff244e31739e", "_version"=>2, "result"=>"deleted", "_shards"=>{"total"=>2, "successful"=>1, "failed"=>0}, "_seq_no"=>1, "_primary_term"=>1})
      expect(described_class.remove_subscription(service: 'blah', url: 'http://blah.com/respond')).to(eq(['http://blah.com/respond']))
    end

    it "fails a search with a too-large offset" do
        expect(API.claim_reviews(offset: 10001)).to(eq({error: "Offset is 10001, and cannot be bigger than 10000. Query cannot execute"}))
    end

    it "includes link data when specified in search query" do
      ClaimReview.stub(:search).with({:offset=>0, :per_page=>20, :include_link_data => true}, true).and_return([{ bloop: 1 }])
      ClaimReview.stub(:enrich_claim_reviews_with_links).with([{ bloop: 1 }]).and_return([{ bloop: 1 }])
      expect(described_class.claim_reviews({include_link_data: true})).to(eq([{ bloop: 1 }]))
    end
  end
end
