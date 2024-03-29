# frozen_string_literal: true

describe LaSillaVacia do
  describe 'instance' do
    it 'has a hostname' do
      expect(described_class.new.hostname).to(eq('https://www.lasillavacia.com'))
    end

    it 'has a fact_list_path' do
      expect(described_class.new.fact_list_path(1)).to(eq('/elementAjax/SillaDetector/MasHistoriasRecientes?page=1'))
    end

    it 'has a url_extraction_search' do
      expect(described_class.new.url_extraction_search).to(eq('a'))
    end

    it 'extracts a url' do
      expect(described_class.new.url_extractor(Nokogiri.parse("<a href='/blah'>wow</a>").search('a')[0])).to(eq('/blah'))
    end

    it 'extracts urls from a non HTML compliant document' do
      raw_response = File.read("spec/fixtures/la_silla_vacia_index_page_response.html")
      described_class.any_instance.stub(:get_url).with(described_class.new.hostname + described_class.new.fact_list_path(1)).and_return(raw_response)
      urls = [
        "http://www.lasillavacia.com/la-silla-vacia/detector-de-mentiras/detector:-en-este-video-iván-márquez-no-se-refiere-al-pacto-histórico",
        "http://www.lasillavacia.com/la-silla-vacia/detector-de-mentiras/detector:-el-tiempo-no-publicó-noticia-sobre-supuesta-relación-del-eln-con-“fico”",
        "http://www.lasillavacia.com/la-silla-vacia/detector-de-mentiras/detector:-lópez-obrador-no-dijo-que-“ser-como-colombia-sería-peor”",
        "http://www.lasillavacia.com/la-silla-vacia/detector-de-mentiras/comunicado-de-tiendas-d1-invitando-a-votar-por-“fico”-es-falso"
      ]
      expect(described_class.new.get_fact_page_urls(1)).to(eq(urls))
    end

    it 'iterates on get_claim_reviews' do
      described_class.any_instance.stub(:store_claim_reviews_for_page).with(1).and_return([{ 'created_at': Time.now - 7 * 24 * 24 * 60 }])
      2.upto(described_class.new.max_pages+2).each do |page|
        described_class.any_instance.stub(:store_claim_reviews_for_page).with(page).and_return([])
      end
      response = described_class.new.get_claim_reviews
      expect(response).to(eq(nil))
    end

    it "checks all status returns for title_classes" do
      expect(described_class.new.claim_review_result_and_score_from_title_classes("border-scale-red")).to(eq([0.0, "False"]))
      expect(described_class.new.claim_review_result_and_score_from_title_classes("border-scale-orange")).to(eq([0.25, "Mostly False"]))
      expect(described_class.new.claim_review_result_and_score_from_title_classes("border-scale-yellow")).to(eq([0.5, "Debatable"]))
      expect(described_class.new.claim_review_result_and_score_from_title_classes("border-scale-ligth-green")).to(eq([0.75, "Mostly True"]))
      expect(described_class.new.claim_review_result_and_score_from_title_classes("border-scale-green")).to(eq([1.0, "True"]))
    end

    it 'parses a raw_claim_review' do
      raw = JSON.parse(File.read('spec/fixtures/la_silla_vacia_raw.json'))
      raw['page'] = Nokogiri.parse(raw['page'])
      parsed_claim = described_class.new.parse_raw_claim_review(raw)
      expect(parsed_claim.class).to(eq(Hash))
      ClaimReview.mandatory_fields.each do |field|
        expect(QuietHashie[parsed_claim][field].nil?).to(eq(false))
      end
    end
  end
end
