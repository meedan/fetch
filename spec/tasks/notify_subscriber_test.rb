# frozen_string_literal: true

describe NotifySubscriber do
  before do
    stub_request(:post, "http://blah.com/respond").
    with(
      body: /.*/,
      headers: {
  	  'Accept'=>'*/*',
  	  'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
  	  'Content-Length'=>/.*/,
  	  'Host'=>'blah.com',
  	  'User-Agent'=>/.*/
      }).
    to_return(status: 200, body: "", headers: {})
    stub_request(:post, "http://blah.com/respond2").
    with(
      body: /.*/,
      headers: {
  	  'Accept'=>'*/*',
  	  'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
  	  'Content-Length'=>/.*/,
  	  'Host'=>'blah.com',
  	  'User-Agent'=>/.*/
      }).
    to_return(status: 200, body: "", headers: {})
  end

  describe 'instance' do
    it 'responds to perform' do
      StoredSubscriptionRepository.any_instance.stub(:save).with(anything).and_return({ _index: Settings.get('es_index_name_stored_subscription'), _type: Settings.get('es_index_name_stored_subscription'), _id: 'vhV84XIBOGf2XeyOAD12', _version: 1, result: 'created', _shards: { total: 2, successful: 1, failed: 0 }, _seq_no: 130_821, _primary_term: 2 })
      StoredSubscriptionRepository.any_instance.stub(:delete).with(anything).and_return({"_index"=>Settings.get('es_index_name_stored_subscription'), "_type"=>"_doc", "_id"=>"4471b889d47383cb6c4cff244e31739e", "_version"=>2, "result"=>"deleted", "_shards"=>{"total"=>2, "successful"=>1, "failed"=>0}, "_seq_no"=>1, "_primary_term"=>1})
      Elasticsearch::Client.any_instance.stub(:search).with(anything).and_return({ 'hits' => { 'hits' => [{ '_source' => {"id"=>"4471b889d47383cb6c4cff244e31739e", "service"=>"tempo_cekfakta", "subscription_url"=>"http://blah.com/respond", "params"=>{"language"=>["en"]}.to_json} }, { '_source' => {"id"=>"4471b889d47383cb6c4cff244e31739e", "service"=>"tempo_cekfakta", "subscription_url"=>"http://blah.com/respond2", "params"=>{"language"=>[]}.to_json} }] } })
      Subscription.add_subscription("blah", "http://blah.com/respond", "en")
      Subscription.add_subscription("blah", "http://blah.com/respond2")
      response = described_class.new.perform('blah', {})
      Subscription.remove_subscription("blah", "http://blah.com/respond")
      Subscription.remove_subscription("blah", "http://blah.com/respond2")
      expect(response).to(eq([{"http://blah.com/respond"=>{"language"=>["en"]}, "http://blah.com/respond2"=>{"language"=>[]}}]))
    end
  end
end
