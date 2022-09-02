# frozen_string_literal: true

describe Tsek do
  before do
    stub_request(:get, "https://www.tsek.ph/wp-json/newspack-blocks/v1/articles?className=is-style-borders&columns=3&customTextColor&disableImageLazyLoad=0&excerptLength=55&exclude_ids=&imageScale=3&imageShape=uncropped&mediaPosition=left&minHeight=0&mobileStack=1&moreButton=1&moreButtonText&page=2&postLayout=list&postType%255B0%255D=post&postsToShow=20&readMoreLabel=Keep%2520reading&sectionHeader&showAuthor=1&showAvatar=1&showCaption=0&showCategory=0&showDate=1&showExcerpt=1&showImage=1&showReadMore=0&showSubtitle=0&singleMode=0&specificMode=0&textAlign=left&textColor&typeScale=4").
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
      expect(described_class.new.get_page_urls[0]).to(eq("https://www.tsek.ph/70-million-katao-dumalo-sa-leni-kiko-grand-rally-sa-bacolod/"))
    end

    it 'returns get_new_fact_page_urls' do
      described_class.any_instance.stub(:get_existing_urls).with(anything).and_return([])
      expect(described_class.new.get_new_fact_page_urls(1)[0]).to(eq("https://www.tsek.ph/70-million-katao-dumalo-sa-leni-kiko-grand-rally-sa-bacolod/"))
    end

    it 'parses a raw_claim_review' do
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
