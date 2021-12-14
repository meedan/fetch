# frozen_string_literal: true

describe Subscription do
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
  describe 'class' do
    it 'responds to keyname' do
      expect(described_class.keyname('blah')).to(eq('claim_review_webhooks_blah'))
    end

    it 'responds to add_subscription' do
      Elasticsearch::Client.any_instance.stub(:search).with(anything).and_return({ 'hits' => { 'hits' => [{ '_source' => {"id"=>"4471b889d47383cb6c4cff244e31739e", "service"=>"tempo_cekfakta", "subscription_url"=>"http://blah.com/respond", "params"=>{"language"=>[]}} }] } })
      StoredSubscriptionRepository.any_instance.stub(:save).with(anything).and_return({ _index: Settings.get('es_index_name_stored_subscription'), _type: Settings.get('es_index_name_stored_subscription'), _id: 'vhV84XIBOGf2XeyOAD12', _version: 1, result: 'created', _shards: { total: 2, successful: 1, failed: 0 }, _seq_no: 130_821, _primary_term: 2 })
      expect(described_class.add_subscription('blah', 'http://blah.com/respond')).to(eq([{ _index: Settings.get('es_index_name_stored_subscription'), _type: Settings.get('es_index_name_stored_subscription'), _id: 'vhV84XIBOGf2XeyOAD12', _version: 1, result: 'created', _shards: { total: 2, successful: 1, failed: 0 }, _seq_no: 130_821, _primary_term: 2 }]))
    end

    it 'responds to remove_subscription' do
      StoredSubscriptionRepository.any_instance.stub(:delete).with(anything).and_return({"_index"=>Settings.get('es_index_name_stored_subscription'), "_type"=>"_doc", "_id"=>"4471b889d47383cb6c4cff244e31739e", "_version"=>2, "result"=>"deleted", "_shards"=>{"total"=>2, "successful"=>1, "failed"=>0}, "_seq_no"=>1, "_primary_term"=>1})
      Elasticsearch::Client.any_instance.stub(:search).with(anything).and_return({ 'hits' => { 'hits' => [{ '_source' => {"id"=>"4471b889d47383cb6c4cff244e31739e", "service"=>"tempo_cekfakta", "subscription_url"=>"http://blah.com/respond", "params"=>{"language"=>[]}} }] } })
      expect(described_class.remove_subscription('blah', 'http://blah.com/respond')).to(eq([{"_index"=>Settings.get('es_index_name_stored_subscription'), "_type"=>"_doc", "_id"=>"4471b889d47383cb6c4cff244e31739e", "_version"=>2, "result"=>"deleted", "_shards"=>{"total"=>2, "successful"=>1, "failed"=>0}, "_seq_no"=>1, "_primary_term"=>1}]))
    end

    it 'responds to get_subscriptions' do
      Elasticsearch::Client.any_instance.stub(:search).with(anything).and_return({ 'hits' => { 'hits' => [{ '_source' => {"id"=>"4471b889d47383cb6c4cff244e31739e", "service"=>"tempo_cekfakta", "subscription_url"=>"http://blah.com/respond", "params"=>{"language"=>[]}} }] } })
      expect(described_class.get_subscriptions('blah').class).to(eq(Hash))
    end

    it 'responds to notify_subscribers' do
      Elasticsearch::Client.any_instance.stub(:search).with(anything).and_return({ 'hits' => { 'hits' => [{ '_source' => {"id"=>"4471b889d47383cb6c4cff244e31739e", "service"=>"tempo_cekfakta", "subscription_url"=>"http://blah.com/respond", "params"=>{"language"=>[]}} }] } })
      StoredSubscriptionRepository.any_instance.stub(:save).with(anything).and_return({ _index: Settings.get('es_index_name_stored_subscription'), _type: Settings.get('es_index_name_stored_subscription'), _id: 'vhV84XIBOGf2XeyOAD12', _version: 1, result: 'created', _shards: { total: 2, successful: 1, failed: 0 }, _seq_no: 130_821, _primary_term: 2 })
      StoredSubscriptionRepository.any_instance.stub(:delete).with(anything).and_return({"_index"=>Settings.get('es_index_name_stored_subscription'), "_type"=>"_doc", "_id"=>"4471b889d47383cb6c4cff244e31739e", "_version"=>2, "result"=>"deleted", "_shards"=>{"total"=>2, "successful"=>1, "failed"=>0}, "_seq_no"=>1, "_primary_term"=>1})
      described_class.add_subscription("blah", "http://blah.com/respond", "en")
      described_class.add_subscription("blah", "http://blah.com/respond2")
      response = described_class.notify_subscribers('blah', {inLanguage: "en"})
      described_class.remove_subscription("blah", "http://blah.com/respond")
      described_class.remove_subscription("blah", "http://blah.com/respond2")
      expect(response.class).to(eq(Array))
    end

    it 'responds to notify_subscribers' do
      Elasticsearch::Client.any_instance.stub(:search).with(anything).and_return({ 'hits' => { 'hits' => [{ '_source' => {"id"=>"4471b889d47383cb6c4cff244e31739e", "service"=>"tempo_cekfakta", "subscription_url"=>"http://blah.com/respond", "params"=>{"language"=>[]}} }] } })
      StoredSubscriptionRepository.any_instance.stub(:save).with(anything).and_return({ _index: Settings.get('es_index_name_stored_subscription'), _type: Settings.get('es_index_name_stored_subscription'), _id: 'vhV84XIBOGf2XeyOAD12', _version: 1, result: 'created', _shards: { total: 2, successful: 1, failed: 0 }, _seq_no: 130_821, _primary_term: 2 })
      StoredSubscriptionRepository.any_instance.stub(:delete).with(anything).and_return({"_index"=>Settings.get('es_index_name_stored_subscription'), "_type"=>"_doc", "_id"=>"4471b889d47383cb6c4cff244e31739e", "_version"=>2, "result"=>"deleted", "_shards"=>{"total"=>2, "successful"=>1, "failed"=>0}, "_seq_no"=>1, "_primary_term"=>1})
      described_class.add_subscription("blah", "http://blah.com/respond", "en")
      described_class.add_subscription("blah", "http://blah.com/respond2")
      described_class.stub(:send_webhook_notification).with(anything(), anything(), anything()).and_raise(RestClient::ServiceUnavailable)
      expect { described_class.notify_subscribers('blah', {}) }.to raise_error(RestClient::ServiceUnavailable)
      described_class.add_subscription("blah", "http://blah.com/respond")
      described_class.remove_subscription("blah", "http://blah.com/respond2")
    end
    
    it 'indicates no sending for mismatched languages' do
      expect(described_class.claim_review_can_be_sent("http://blah.com/respond", {'language' => ["en"]}, {inLanguage: "es"})).to(eq(false))
    end

    it 'indicates no sending for mismatched languages' do
      expect(described_class.claim_review_can_be_sent("http://blah.com/respond", {'language' => []}, {inLanguage: "es"})).to(eq(true))
    end

    it 'adds subscription with languages passed' do
      StoredSubscriptionRepository.any_instance.stub(:save).with(anything).and_return({ _index: Settings.get('es_index_name_stored_subscription'), _type: Settings.get('es_index_name_stored_subscription'), _id: 'vhV84XIBOGf2XeyOAD12', _version: 1, result: 'created', _shards: { total: 2, successful: 1, failed: 0 }, _seq_no: 130_821, _primary_term: 2 })
      Elasticsearch::Client.any_instance.stub(:search).with(anything).and_return({ 'hits' => { 'hits' => [{ '_source' => {"id"=>"4471b889d47383cb6c4cff244e31739e", "service"=>"tempo_cekfakta", "subscription_url"=>"http://blah.com/respond", "params"=>{"language"=>[]}} }] } })
      described_class.add_subscription("blah", "http://blah.com/respond", "en")
      expect(described_class.get_existing_params_for_url("blah", "http://blah.com/respond")).to(eq({"language"=>["en"]}))
    end

    it 'removes subscription with languages passed' do
      Elasticsearch::Client.any_instance.stub(:search).with(anything).and_return({ 'hits' => { 'hits' => [] } })
      StoredSubscriptionRepository.any_instance.stub(:save).with(anything).and_return({ _index: Settings.get('es_index_name_stored_subscription'), _type: Settings.get('es_index_name_stored_subscription'), _id: 'vhV84XIBOGf2XeyOAD12', _version: 1, result: 'created', _shards: { total: 2, successful: 1, failed: 0 }, _seq_no: 130_821, _primary_term: 2 })
      StoredSubscriptionRepository.any_instance.stub(:delete).with(anything).and_return({"_index"=>Settings.get('es_index_name_stored_subscription'), "_type"=>"_doc", "_id"=>"4471b889d47383cb6c4cff244e31739e", "_version"=>2, "result"=>"deleted", "_shards"=>{"total"=>2, "successful"=>1, "failed"=>0}, "_seq_no"=>1, "_primary_term"=>1})
      described_class.add_subscription("blah", "http://blah.com/respond", "en")
      described_class.remove_subscription("blah", "http://blah.com/respond")
      expect(described_class.get_subscriptions('blah')).to(eq({"blah"=>{}}))
    end
  end
end

