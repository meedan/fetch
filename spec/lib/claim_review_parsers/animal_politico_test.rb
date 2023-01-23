# frozen_string_literal: true

describe AnimalPolitico do
  before do
    stub_request(:get, "https://admin.animalpolitico.com/index.php/wp-json/wp/v2/elsabueso?calificacion=&per_page=50&page=1").
      with(
        headers: {
    	  'Accept'=>'*/*',
    	  'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
    	  'Host'=>'admin.animalpolitico.com',
        "User-Agent": /.*/
        }).
      to_return(status: 200, body: File.read("spec/fixtures/animal_politico_index.json"), headers: {})
  end
  before do
    stub_request(:get, "https://admin.animalpolitico.com/index.php/wp-json/wp/v2/elsabueso?categoria=desinformacion&per_page=50&page=1").
      with(
        headers: {
    	  'Accept'=>'*/*',
    	  'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
    	  'Host'=>'admin.animalpolitico.com',
        "User-Agent": /.*/
        }).
      to_return(status: 200, body: File.read("spec/fixtures/animal_politico_index.json"), headers: {})
  end
  before do
    stub_request(:get, "https://admin.animalpolitico.com/index.php/wp-json/wp/v2/elsabueso?categoria=teexplico&per_page=50&page=1").
      with(
        headers: {
    	  'Accept'=>'*/*',
    	  'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
    	  'Host'=>'admin.animalpolitico.com',
        "User-Agent": /.*/
        }).
      to_return(status: 200, body: File.read("spec/fixtures/animal_politico_index.json"), headers: {})
  end
  describe 'instance' do
    it 'runs get_claim_reviews' do
      described_class.any_instance.stub(:store_to_db).with(anything, anything).and_return(true)
      described_class.any_instance.stub(:get_existing_urls).with(anything).and_return([])
      described_class.any_instance.stub(:get_parsed_fact_pages_from_urls).with(anything).and_return([])
      expect(described_class.new.get_claim_reviews.class).to(eq(NilClass))
    end

    it 'parses a raw_claim_review' do
      raw = JSON.parse(File.read('spec/fixtures/animal_politico_raw.json'))
      parsed_claim = described_class.new.parse_raw_claim_review(raw)
      expect(parsed_claim.class).to(eq(Hash))
      ClaimReview.mandatory_fields.each do |field|
        expect(QuietHashie[parsed_claim][field].nil?).to(eq(false))
      end
    end
  end
end
