# frozen_string_literal: true

describe Tsek do
  before do
    stub_request(:get, "https://www.tsek.ph/wp-json/newspack-blocks/v1/articles?className=is-style-borders&imageShape=uncropped&moreButton=1&postsToShow=20&mediaPosition=left&mobileStack=1&showExcerpt=1&excerptLength=55&showReadMore=0&readMoreLabel=Keep%20reading&showDate=1&showImage=1&showCaption=0&disableImageLazyLoad=0&minHeight=0&moreButtonText&showAuthor=1&showAvatar=1&showCategory=0&postLayout=list&columns=3&&&&&&&typeScale=4&imageScale=3&sectionHeader&specificMode=0&textColor&customTextColor&singleMode=0&showSubtitle=0&postType%5B0%5D=post&textAlign=left&page=2&exclude_ids=").
      with(
        headers: {
      	  'Accept'=>'*/*',
      	  'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
      	  'Host'=>'www.tsek.ph',
      	  'User-Agent'=>/.*/
        }).
      to_return(status: 200, body: File.read("spec/fixtures/tsek_index_response.json"), headers: {})
  end

  describe 'instance' do
    it 'has a hostname' do
      expect(described_class.new.hostname).to(eq('https://www.tsek.ph'))
    end

    it 'requests a fact page' do
      expect(described_class.new.request_fact_page.class).to(eq(RestClient::Response))      
    end

    it 'gets urls from a fact page' do
      expect(described_class.new.get_page_urls).to(eq(["/blah", "/blah2"]))
    end

    it 'gets a created_at from a raw_claim_review' do
      expect(described_class.new.created_at_from_raw_claim_review({"page" => Nokogiri.parse("<html><body><div id='primary'><div class='cs-meta-date'>29/01/2021</div></div></body></html>")})).to(eq("29/01/2021"))
    end

    it 'returns get_new_fact_page_urls' do
      described_class.any_instance.stub(:get_existing_urls).with(anything).and_return([])
      expect(described_class.new.get_new_fact_page_urls(1)).to(eq(["/blah", "/blah2"]))
    end

    it 'parses a raw_claim_review' do
      binding.pry
      raw = JSON.parse(File.read('spec/fixtures/tsek_raw.json'))
      raw['page'] = Nokogiri.parse(raw['page'])
      parsed_claim = described_class.new.parse_raw_claim_review(raw)
      expect(parsed_claim.class).to(eq(Hash))
      ClaimReview.mandatory_fields.each do |field|
        expect(QuietHashie[parsed_claim][field].nil?).to(eq(false))
      end
    end
  end
end
