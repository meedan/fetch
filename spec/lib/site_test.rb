# frozen_string_literal: true

describe Site do
  include Rack::Test::Methods

  def app
    Site
  end

  describe 'endpoints' do
    it 'returns an empty GET claim_reviews response' do
      response = get "/ping"
      expect(response.status).to(eq(200))
      expect(JSON.parse(response.body)).to(eq({"pong" => true}))
    end

    it 'returns an empty GET claim_reviews response' do
      ClaimReview.stub(:search).with({:offset=>0, :per_page=>20}, true).and_return([])
      response = get "/claim_reviews"
      expect(response.status).to(eq(200))
      expect(JSON.parse(response.body)).to(eq([]))
    end

    it 'returns a non-empty GET claim_reviews response' do
      ClaimReview.stub(:search).with({:offset=>0, :per_page=>20}, true).and_return([{ bloop: 1 }])
      response = get "/claim_reviews"
      expect(response.status).to(eq(200))
      expect(JSON.parse(response.body)).to(eq([{ 'bloop' => 1 }]))
    end

    it 'returns an about page' do
      response = get "/about"
      expect(response.status).to(eq(200))
      expect(JSON.parse(response.body).class).to(eq(Hash))
    end

    it 'returns a services page' do
      Elasticsearch::Client.any_instance.stub(:search).with(anything()).and_return({"took"=>21, "timed_out"=>false, "_shards"=>{"total"=>1, "successful"=>1, "skipped"=>0, "failed"=>0}, "hits"=>{"total"=>14055, "max_score"=>2.1063054, "hits"=>[{"_source" => {"created_at" => "2020-01-01", "_index"=>"claim_reviews", "_type"=>"claim_review", "id"=>"0f6a429f5a4e6d017b152665f9cdcadc"}}]}})
      response = get "/services"
      expect(response.status).to(eq(200))
      expect(JSON.parse(response.body).class).to(eq(Hash))
    end

    it 'gets subscriptions' do
      Elasticsearch::Client.any_instance.stub(:search).with(anything).and_return({ 'hits' => { 'hits' => [{ '_source' => {"id"=>"4471b889d47383cb6c4cff244e31739e", "service"=>"tempo_cekfakta", "subscription_url"=>"http://blah.com/respond", "params"=>{"language"=>[]}.to_json} }] } })
      StoredSubscriptionRepository.any_instance.stub(:save).with(anything).and_return({ _index: Settings.get('es_index_name_stored_subscription'), _type: Settings.get('es_index_name_stored_subscription'), _id: 'vhV84XIBOGf2XeyOAD12', _version: 1, result: 'created', _shards: { total: 2, successful: 1, failed: 0 }, _seq_no: 130_821, _primary_term: 2 })
      response = get "/subscribe", "service=blah"
      expect(response.status).to(eq(200))
      expect(JSON.parse(response.body).class).to(eq(Hash))
    end

    it 'adds subscriptions' do
      Elasticsearch::Client.any_instance.stub(:search).with(anything).and_return({ 'hits' => { 'hits' => [{ '_source' => {"id"=>"4471b889d47383cb6c4cff244e31739e", "service"=>"tempo_cekfakta", "subscription_url"=>"http://blah.com/respond", "params"=>{"language"=>[]}.to_json} }] } })
      StoredSubscriptionRepository.any_instance.stub(:save).with(anything).and_return({ _index: Settings.get('es_index_name_stored_subscription'), _type: Settings.get('es_index_name_stored_subscription'), _id: 'vhV84XIBOGf2XeyOAD12', _version: 1, result: 'created', _shards: { total: 2, successful: 1, failed: 0 }, _seq_no: 130_821, _primary_term: 2 })
      response = post "/subscribe", {service: 'blah', url: 'http://blah.com/respond'}.to_json
      expect(response.status).to(eq(200))
      expect(JSON.parse(response.body)).to(eq({"blah" => {"http://blah.com/respond"=>{"language"=>[]}}}))
    end

    it 'removes subscriptions' do
      Elasticsearch::Client.any_instance.stub(:search).with(anything).and_return({ 'hits' => { 'hits' => [] } })
      StoredSubscriptionRepository.any_instance.stub(:delete).with(anything).and_return({"_index"=>Settings.get('es_index_name_stored_subscription'), "_type"=>"_doc", "_id"=>"4471b889d47383cb6c4cff244e31739e", "_version"=>2, "result"=>"deleted", "_shards"=>{"total"=>2, "successful"=>1, "failed"=>0}, "_seq_no"=>1, "_primary_term"=>1})
      response = delete "/subscribe", {service: 'blah', url: 'http://blah.com/respond'}.to_json
      expect(response.status).to(eq(200))
      expect(JSON.parse(response.body)).to(eq({"blah" => {}}))
    end
  end
end
