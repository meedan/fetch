# frozen_string_literal: true

describe UOLComprova do
  before do
    stub_request(:get, "https://noticias.uol.com.br/comprova/?next=").with(
       headers: {
   	  'Accept'=>'*/*',
   	  'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
  	  'Host'=>'noticias.uol.com.br',
      "User-Agent": /.*/
       }).
     to_return(status: 200, body: "<html><body><div class='collection-standard'><section class='latest-news-banner'><div class='container'><section class='results-index'><div class='thumbnails-item'><a href='/blah'>link</a></div></section></div></section></div><button class='btn-search' data-next='blah2' /></body></html>", headers: {})

    stub_request(:get, "https://noticias.uol.com.br/comprova/?next=blah").with(
       headers: {
   	  'Accept'=>'*/*',
   	  'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
  	  'Host'=>'noticias.uol.com.br',
      "User-Agent": /.*/
       }).
     to_return(status: 200, body: "<html><body><button class='btn-search' data-next='blah2' /></body></html>", headers: {})

     stub_request(:get, "https://noticias.uol.com.br/comprova/?next=blah2").with(
        headers: {
    	  'Accept'=>'*/*',
    	  'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
   	  'Host'=>'noticias.uol.com.br',
       "User-Agent": /.*/
        }).
      to_return(status: 200, body: "<html><body><button class='btn-search' data-next='blah3' /></body></html>", headers: {})
  end
  describe 'instance' do
    it 'has a hostname' do
      expect(described_class.new.hostname).to(eq('https://noticias.uol.com.br'))
    end

    it 'has a fact_list_path' do
      expect(described_class.new.fact_list_path("blah")).to(eq('/comprova/?next=blah'))
    end

    it 'has a url_extraction_search' do
      expect(described_class.new.url_extraction_search).to(eq("div.collection-standard section.latest-news-banner div.container section.results-index div.thumbnails-item a"))
    end

    it 'extracts a url' do
      expect(described_class.new.url_extractor(Nokogiri.parse("<a href='/blah'>wow</a>").search('a')[0])).to(eq('/blah'))
    end

    it 'side-effects a @next_page item while getting a page' do
      instance = described_class.new
      response = instance.parsed_fact_list_page("blah")
      expect(instance.next_page).to(eq("blah2"))
    end

    it 'walks through get_claim_reviews' do
      ClaimReview.stub(:existing_urls).with(anything, described_class.service).and_return([])
      expect(described_class.new.get_claim_reviews).to(eq(nil))
    end

    it 'parses a raw_claim_review' do
      raw = JSON.parse(File.read('spec/fixtures/uol_comprova_raw.json'))
      raw['page'] = Nokogiri.parse(raw['page'])
      parsed_claim = described_class.new.parse_raw_claim_review(raw)
      expect(parsed_claim.class).to(eq(Hash))
      ClaimReview.mandatory_fields.each do |field|
        expect(QuietHashie[parsed_claim][field].nil?).to(eq(false))
      end
    end
  end
end