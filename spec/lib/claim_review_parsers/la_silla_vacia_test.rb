# frozen_string_literal: true

describe LaSillaVacia do
  describe 'instance' do
    it 'has a hostname' do
      expect(described_class.new.hostname).to(eq('https://www.altnews.in/'))
    end

    it 'has a fact_list_path' do
      expect(described_class.new.fact_list_path(1)).to(eq('/page/1/'))
    end

    it 'has a url_extraction_search' do
      expect(described_class.new.url_extraction_search).to(eq('article .entry-title a'))
    end

    it 'extracts a url' do
      expect(described_class.new.url_extractor(Nokogiri.parse("<a href='/blah'>wow</a>").search('a')[0])).to(eq('/blah'))
    end

    it 'rescues against a claim_review_image_url_from_raw_claim_review' do
      expect(described_class.new.claim_review_image_url_from_raw_claim_review({"page" => Nokogiri.parse("<a href='/blah'>wow</a>")})).to(eq(nil))
    end

    it 'parses a raw_claim_review' do
      raw = JSON.parse(File.read('spec/fixtures/la_silla_vacia.json'))
      raw['page'] = Nokogiri.parse(raw['page'])
      parsed_claim = described_class.new.parse_raw_claim_review(raw)
      expect(parsed_claim.class).to(eq(Hash))
      ClaimReview.mandatory_fields.each do |field|
        expect(QuietHashie[parsed_claim][field].nil?).to(eq(false))
      end
    end
  end
  # describe 'instance' do
  #   it 'has a hostname' do
  #     expect(described_class.new.hostname).to(eq('https://www.lasillavacia.com'))
  #   end
  #
  #   it 'has a fact_list_path' do
  #     expect(described_class.new.fact_list_path(1)).to(eq('/elementAjax/SillaDetector/MasHistoriasRecientes?page=1'))
  #   end
  #
  #   it 'has a url_extraction_search' do
  #     expect(described_class.new.url_extraction_search).to(eq('a'))
  #   end
  #
  #   it 'extracts a url' do
  #     expect(described_class.new.url_extractor(Nokogiri.parse("<a href='/blah'>wow</a>").search('a')[0])).to(eq('/blah'))
  #   end
  #
  #   it "checks all status returns for title_classes" do
  #     expect(described_class.new.claim_review_result_and_score_from_title_classes("border-scale-red")).to(eq([0.0, "False"]))
  #     expect(described_class.new.claim_review_result_and_score_from_title_classes("border-scale-orange")).to(eq([0.33, "Mostly False"]))
  #     expect(described_class.new.claim_review_result_and_score_from_title_classes("border-scale-ligth-green")).to(eq([0.66, "Mostly True"]))
  #     expect(described_class.new.claim_review_result_and_score_from_title_classes("border-scale-green")).to(eq([1.0, "True"]))
  #   end
  #
  #   it 'parses a raw_claim_review' do
  #     raw = JSON.parse(File.read('spec/fixtures/la_silla_vacia_raw.json'))
  #     raw['page'] = Nokogiri.parse(raw['page'])
  #     parsed_claim = described_class.new.parse_raw_claim_review(raw)
  #     expect(parsed_claim.class).to(eq(Hash))
  #     ClaimReview.mandatory_fields.each do |field|
  #       expect(QuietHashie[parsed_claim][field].nil?).to(eq(false))
  #     end
  #   end
  # end
end
