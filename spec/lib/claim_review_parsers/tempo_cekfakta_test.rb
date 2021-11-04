# frozen_string_literal: true

describe TempoCekfakta do
  before do
    stub_request(:get, "https://cekfakta.tempo.co/#{Time.now.strftime("%Y/%m")}").
      with(
        headers: {
    	  'Accept'=>'*/*',
    	  'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
    	  'Host'=>'cekfakta.tempo.co',
    	  'User-Agent'=>'Meedan Data Crawler'
        }).
      to_return(status: 200, body: File.read('spec/fixtures/tempo_cekfakta_index_page.html'), headers: {})

      stub_request(:get, "https://cekfakta.tempo.co/#{DateTime.now.prev_month.strftime("%Y/%m")}").
        with(
          headers: {
      	  'Accept'=>'*/*',
      	  'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
      	  'Host'=>'cekfakta.tempo.co',
      	  'User-Agent'=>'Meedan Data Crawler'
          }).
        to_return(status: 200, body: "", headers: {})
  end

  describe 'instance' do
    it 'has a hostname' do
      expect(described_class.new.hostname).to(eq('https://cekfakta.tempo.co'))
    end

    it 'has a fact_list_path' do
      expect(described_class.new.fact_list_path(DateTime.now)).to(eq("/#{DateTime.now.year}/#{DateTime.now.strftime("%m")}"))
    end

    it 'correctly parses an index page' do
      Elasticsearch::Transport::Client.any_instance.stub(:search).with(anything).and_return({ 'hits' => { 'hits' => [] } })
      AlegreClient.stub(:get_enrichment_for_url).with(anything).and_return({"text" => "blah", "links" => ["http://example.com"]})
      PenderClient.stub(:get_enrichment_for_url).with(anything).and_return(JSON.parse(File.read("spec/fixtures/pender_response.json")))
      ClaimReviewSocialDataRepository.any_instance.stub(:save).with(anything).and_return({ _index: Settings.get('es_index_name_cr_social_data'), _type: Settings.get('es_index_name_cr_social_data'), _id: 'vhV84XIBOGf2XeyOAD12', _version: 1, result: 'created', _shards: { total: 2, successful: 1, failed: 0 }, _seq_no: 130_821, _primary_term: 2 })
      ClaimReviewRepository.any_instance.stub(:save).with(anything).and_return({ _index: 'claim_reviews', _type: 'claim_review', _id: 'vhV84XIBOGf2XeyOAD12', _version: 1, result: 'created', _shards: { total: 2, successful: 1, failed: 0 }, _seq_no: 130_821, _primary_term: 2 })
      described_class.any_instance.stub(:parsed_page_from_url).with(anything).and_return(Nokogiri.parse(JSON.parse(File.read("spec/fixtures/tempo_cekfakta_raw.json"))["page"]))
      datetime = DateTime.now
      response = described_class.new.get_claim_reviews(datetime)
      expect(response).to(eq(nil))
      # https://cekfakta.tempo.co/2020/11
      AlegreClient.unstub(:get_enrichment_for_url)
      PenderClient.unstub(:get_enrichment_for_url)
    end

    it 'parses a raw_claim_review' do
      raw = JSON.parse(File.read('spec/fixtures/tempo_cekfakta_raw.json'))
      raw['page'] = Nokogiri.parse(raw['page'])
      parsed_claim = described_class.new.parse_raw_claim_review(raw)
      expect(parsed_claim.class).to(eq(Hash))
      ClaimReview.mandatory_fields.each do |field|
        expect(QuietHashie[parsed_claim][field].nil?).to(eq(false))
      end
    end
  end
end
