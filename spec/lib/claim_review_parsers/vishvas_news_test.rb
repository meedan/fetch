# frozen_string_literal: true
describe VishvasNews do
  before do
    stub_request(:post, "https://www.vishvasnews.com/wp-admin/admin-ajax.php").
      with(
        body: /.*/,
        headers: {
    	  'Accept'=>'*/*',
    	  'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
    	  'Content-Length'=>/.*/,
    	  'Host'=>'www.vishvasnews.com',
    	  'User-Agent'=>/.*/
        }).
      to_return(status: 200, body: File.read("spec/fixtures/vishvas_news_index_raw.html"), headers: {})
  end

  describe 'instance' do
    it 'has a hostname' do
      expect(described_class.new.hostname).to(eq('https://www.vishvasnews.com'))
    end

    it 'has a fact_list_path' do
      expect(described_class.new.fact_page_params(1)).to(eq({action: "ajax_pagination", query_vars: "[]", page: "0", loadPage: "file-latest-posts-part"}))

    end
    it 'returns get_new_fact_page_urls' do
      described_class.any_instance.stub(:get_existing_urls).with(anything).and_return([])
      expect(described_class.new.get_new_fact_page_urls(1)).to(eq(["https://www.vishvasnews.com/viral/fact-check-electricity-water-and-gas-are-not-free-in-turkmenistan-anymore-misleading-claim-viral-again/", "https://www.vishvasnews.com/viral/fact-check-bihar-local-train-falsely-link-to-prayagraj-uppet-exam/", "https://www.vishvasnews.com/politics/fact-check-a-video-of-an-ed-raid-on-a-kolkata-businessman-is-being-shared-with-the-misleading-claims-in-the-name-of-pfi/", "https://www.vishvasnews.com/viral/fact-check-poster-of-shahrukh-khans-film-pathan-not-displayed-on-burj-khalifa-fake-post-goes-viral/", "https://www.vishvasnews.com/politics/fact-check-priyanka-gandhis-tongue-slipped-in-himachal-incomplete-video-viral-with-wrong-reference/", "https://www.vishvasnews.com/viral/fact-check-old-video-of-bangladesh-train-viral-in-the-name-of-ups-pet-exam/", "https://www.vishvasnews.com/viral/fact-check-viral-photo-is-not-related-to-kerala-babiya-croc-odile/", "https://www.vishvasnews.com/politics/fact-check-azam-khan-did-not-shave-his-head-on-the-death-of-mulayam-singh-yadav-the-viral-photo-is-fake/", "https://www.vishvasnews.com/politics/fact-check-an-old-and-unrelated-image-of-a-religious-gathering-in-nigeria-is-being-shared-as-a-rally-of-rahul-gandhi-in-bellari-under-bharat-jodo-yatra/", "https://www.vishvasnews.com/politics/fact-check-old-picture-of-aap-gujarat-chief-gopal-kataria-viral-as-recent/", "https://www.vishvasnews.com/politics/fact-check-this-viral-post-related-to-rahul-gandhi-and-narendra-modi-is-fake/", "https://www.vishvasnews.com/viral/fact-check-in-the-name-of-pet-exam-of-up-the-old-video-of-mumbai-local-train-is-being-made-viral/", "https://www.vishvasnews.com/world/fact-check-qatar-government-did-not-release-this-viral-graphics-ahead-of-fifa-world-cup-2022/", "https://www.vishvasnews.com/viral/fact-check-old-video-of-women-fight-in-etah-now-viral-after-karwachaoth-as-prayagraj-video/", "https://www.vishvasnews.com/politics/fact-check-viral-message-about-education-of-bihar-ministers-in-misleading-2/"]))
    end

    it 'extracts a url' do
      expect(described_class.new.url_extractor(Nokogiri.parse("<a href='/blah'>wow</a>").search('a')[0])).to(eq('/blah'))
    end

    it 'parses a raw_claim_review' do
      raw = JSON.parse(File.read('spec/fixtures/vishvas_news_raw.json'))
      raw['page'] = Nokogiri.parse(raw['page'])
      parsed_claim = described_class.new.parse_raw_claim_review(raw)
      expect(parsed_claim.class).to(eq(Hash))
      ClaimReview.mandatory_fields.each do |field|
        expect(QuietHashie[parsed_claim][field].nil?).to(eq(false))
      end
    end
  end
end
