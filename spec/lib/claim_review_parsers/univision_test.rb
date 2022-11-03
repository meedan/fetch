# frozen_string_literal: true

describe Univision do
  describe 'instance' do
    it 'has a hostname' do
      expect(described_class.new.hostname).to(eq('https://syndicator.univision.com'))
    end

    it 'has a fact_list_path' do
      expect(described_class.new.fact_list_path(1)).to(eq('/web-api/widget?wid=$-719170345&offset=0&limit=20&url=https://www.univision.com/temas/detector-de-mentiras&mrpts=1667232059000'))
      expect(described_class.new.fact_list_path(2)).to(eq('/web-api/widget?wid=$-719170345&offset=20&limit=20&url=https://www.univision.com/temas/detector-de-mentiras&mrpts=1667232059000'))
    end

    it 'has a url_extraction_search' do
      urls = [
        "https://www.univision.com/noticias/falso-este-puente-no-lo-destruyo-el-huracan-fiona",
        "https://www.univision.com/noticias/soldados-otan-luchando-ucrania-afirma-video-viral",
        "https://www.univision.com/noticias/falso-reina-isabelii-aparece-video-lanzando-monedas-gente-asiatica",
        "https://www.univision.com/noticias/falso-corte-suprema-vacuna-arnm-dano-irreparable",
        "https://www.univision.com/noticias/no-hay-evidenicas-vinagre-de-sidra-manzana-cura-gastritis",
        "https://www.univision.com/noticias/falso-bonos-socorristas-florida-son-fondos-federales",
        "https://www.univision.com/noticias/falso-nih-no-incluyo-ivermectina-tratamiento-covid",
        "https://www.univision.com/noticias/falso-video-demuestra-familia-real-britanica-son-reptilianos",
        "https://www.univision.com/noticias/enganoso-bill-gates-atenuar-el-sol",
        "https://www.univision.com/noticias/falso-crecimiento-hielo-groenlandia-desmiente-cambio-climatico",
        "https://www.univision.com/noticias/en-pocas-palabras-pobres-minorias-afectadas-cambio-climatico-fotos",
        "https://www.univision.com/noticias/falso-pavarotti-mario-lanza-pelicula-gran-caruso",
        "https://www.univision.com/noticias/verificamos-falsedades-fotos-twitter-reina-isabel-ii-fotos",
        "https://www.univision.com/noticias/falso-perros-isabel-enterrados-vivos",
        "https://www.univision.com/noticias/biden-no-autorizo-venezolanos-volar-eeuu-desde-bogota-sin-visa",
        "https://www.univision.com/noticias/falso-vacuna-novavax-segura-eficaz-antivacunas-kory",
        "https://www.univision.com/noticias/falso-perder-7-kilos-defecando-limpiando-colon",
        "https://www.univision.com/noticias/verdad-bolsas-tela-mas-sostenibles-igual-contaminan",
        "https://www.univision.com/noticias/falso-djokovic-no-juegue-us-open-moderna-veto",
        "https://www.univision.com/noticias/falta-contexto-califoria-redujo-desempleo-no-mayor-crecimiento-empleo-newsom"
      ]
      expect(described_class.new.url_extractor(JSON.parse(File.read("spec/fixtures/univision_index_raw.json")))).to(eq(urls))
    end

    it 'parses a raw_claim_review' do
      raw = JSON.parse(File.read('spec/fixtures/univision_raw.json'))
      raw['page'] = Nokogiri.parse(raw['page'])
      parsed_claim = described_class.new.parse_raw_claim_review(raw)
      expect(parsed_claim.class).to(eq(Hash))
      ClaimReview.mandatory_fields.each do |field|
        expect(QuietHashie[parsed_claim][field].nil?).to(eq(false))
      end
    end

  end
end
