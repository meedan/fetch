# frozen_string_literal: true
class StubReviewJSON < ClaimReviewParser
  include PaginatedReviewClaims
  def initialize
    @fact_list_page_parser = 'json'
  end

  def hostname
    'http://examplejson.com'
  end

  def fact_list_path(page = 1)
    "/get?page=#{page}"
  end

  def url_extractor(response)
    response['page']
  end

  def parse_raw_claim_review(raw_claim_review)
    raw_claim_review
  end
end

describe ClaimReviewParser do
  before do
    stub_request(:get, 'http://examplejson.com/')
      .with(
        headers: {
          Accept: '*/*',
          "Accept-Encoding": 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          Host: 'examplejson.com',
          "User-Agent": /.*/
        }
      )
      .to_return(status: 200, body: '{"blah": 1}', headers: {})
      stub_request(:post, 'http://examplejson.com/')
        .with(
          headers: {
            Accept: '*/*',
            "Accept-Encoding": 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            Host: 'examplejson.com',
            "User-Agent": /.*/
          }
        )
        .to_return(status: 200, body: '', headers: {})
  end

  describe 'instance' do
    it 'pulls get_cookies via s3-esque query' do
      Settings.stub(:get).with('cookie_file').and_return('s3://bucket/cookie_file.json')
      client = Aws::S3::Client.new(stub_responses: true)
      client.stub_responses(:get_object, {body: StringIO.new("{\"claim_review_parser\": true}")})
      claim_review_parser = described_class.new(nil, false, client)
      expect(claim_review_parser.get_cookies(client)).to(eq(true))
    end

    it 'rescues failed get_url' do
      RestClient::Request.stub(:execute).with(anything()).and_raise(RestClient::NotFound)
      expect(StubReviewJSON.new.get_url(StubReviewJSON.new.hostname)).to(eq(nil))
    end

    it 'expects get_url' do
      expect(StubReviewJSON.new.post_url(StubReviewJSON.new.hostname, "").class).to(eq(RestClient::Response))
    end

    it 'expects get_url' do
      expect(StubReviewJSON.new.get_url(StubReviewJSON.new.hostname).class).to(eq(RestClient::Response))
    end

    it 'expects forcefully-emptied get_existing_urls' do
      rp = described_class.new(Time.now - 60 * 60 * 24)
      expect(rp.get_existing_urls(['123'])).to(eq([]))
    end

    it 'expects default attributes' do
      rp = described_class.new
      expect(rp.send('fact_list_page_parser')).to(eq('html'))
      expect(rp.run_in_parallel).to(eq(true))
    end

    it 'expects to be able to parse_raw_claim_reviews in parallel' do
      rp = AFP.new
      AFP.any_instance.stub(:parse_raw_claim_review).with({}).and_return({})
      expect(rp.parse_raw_claim_reviews([{}, {}])).to(eq([{}, {}]))
    end

    it 'expects to verify when a claim review parser needs a service key but config is missing' do
      described_class.any_instance.stub(:service_key).and_return('class_service_key')
      Settings.stub(:blank?).with('class_service_key').and_return(true)
      rp = described_class.new
      expect(rp.service_key_is_needed?).to(eq(true))
    end

    it 'expects to verify when a claim review parser needs a service key and config is present' do
      described_class.any_instance.stub(:service_key).and_return('class_service_key')
      Settings.stub(:blank?).with('class_service_key').and_return(false)
      rp = described_class.new
      expect(rp.service_key_is_needed?).to(eq(false))
    end

  end

  describe 'class' do
    it 'expects service symbol' do
      expect(described_class.service).to(eq(:claim_review_parser))
    end

    it 'expects parsers map' do
      expect(described_class.parsers.keys.map(&:class).uniq).to(eq([String]))
      expect(!described_class.parsers.values.map(&:superclass).uniq.empty?).to(eq(true))
    end

    it 'expects to be able to run' do
      AFP.any_instance.stub(:get_claim_reviews).and_return('stubbed')
      expect(described_class.run('afp')).to(eq('OK'))
    end
  
    it 'rescues broken json' do
      expect(AFP.new.extract_ld_json_script_block(Nokogiri.parse("<html><script type='application/ld+json'>blah</script></html>"), 0)).to(eq(nil))
    end

    it 'tests a parser on a url' do
      RestClient.stub(:get).with(anything).and_return(JSON.parse(File.read('spec/fixtures/india_today_raw.json'))["page"])
      expect(IndiaToday.test_parser_on_url("http://blah.org").class).to(eq(Hash))
    end
  end
end

RSpec.describe "ClaimReviewParser subclasses" do
  before do
    stub_request(:get, "https://www.boomlive.in/video-claiming-hindu-kids-are-being-taught-namaz-in-karnataka-is-misleading/")
      .with(
         headers: {
     	  'Accept'=>'*/*',
     	  'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
     	  'Host'=>'www.boomlive.in',
        "User-Agent": /.*/
         }).
       to_return(status: 200, body: "", headers: {})
     stub_request(:post, "https://yudistira.turnbackhoax.id/api/antihoax/get_authors").
       with(
         body: /.*/,
         headers: {
     	  'Accept'=>'*/*',
     	  'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
     	  'Content-Length'=>/.*/,
     	  'Content-Type'=>'application/x-www-form-urlencoded',
     	  'Host'=>'yudistira.turnbackhoax.id',
     	  'User-Agent'=>/.*/
         }).
       to_return(status: 200, body: '[{"website":"blah","nama":"foo"}]', headers: {})
  end

  (ClaimReviewParser.enabled_subclasses-[StubReviewJSON]).each do |subclass|
    it "ensures #{subclass} returns ES-storable objects" do 
      raw = JSON.parse(File.read("spec/fixtures/#{subclass.service}_raw.json"))
      raw['page'] = Nokogiri.parse(raw['page']) if raw['page']
      parsed_claim_review = subclass.new.parse_raw_claim_review(raw)
      expect(parsed_claim_review.values_at(*(parsed_claim_review.keys-[:raw_claim_review])).collect(&:class).uniq-[NilClass, String, Float, Time, Integer]).to(eq([]))
    end
  end
  (ClaimReviewParser.enabled_subclasses-[StubReviewJSON]).each do |subclass|
    it "ensures #{subclass} can run as a task" do
      subclass.any_instance.stub(:get_claim_reviews).and_return(nil)
      RunClaimReviewParser.stub(:perform_in).and_return(nil)
      expect(RunClaimReviewParser.new.perform(subclass.service)).to(eq(nil))
    end
  end
end
