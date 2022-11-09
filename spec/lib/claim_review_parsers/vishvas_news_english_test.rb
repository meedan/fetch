# frozen_string_literal: true
describe VishvasNewsEnglish do
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
    it 'has a fact_list_path' do
      expect(described_class.new.fact_page_params(1)).to(eq({action: "ajax_pagination", query_vars: "[]", page: "0", loadPage: "file-latest-posts-part", lang: "english"}))

    end
    it 'parses a raw_claim_review' do
      raw = JSON.parse(File.read('spec/fixtures/vishvas_news_english_raw.json'))
      raw['page'] = Nokogiri.parse(raw['page'])
      parsed_claim = described_class.new.parse_raw_claim_review(raw)
      expect(parsed_claim.class).to(eq(Hash))
      ClaimReview.mandatory_fields.each do |field|
        expect(QuietHashie[parsed_claim][field].nil?).to(eq(false))
      end
    end
  end
end
