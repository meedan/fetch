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
        "https://www.20minutes.fr/monde/3293399-20220519-guerre-ukraine-prisonniers-meritent-vivre-selon-depute-russe-dit-convention-geneve",
        "https://www.20minutes.fr/monde/ukraine/3292711-20220519-guerre-ukraine-telegram-cyber-soldats-amateurs-tentent-rallier-opinion-russe-garanties",
        "https://www.20minutes.fr/monde/3292431-20220519-robes-courtes-interdites-ecole-allemande-demande-professeurs-issus-immigration-faux",
        "https://www.20minutes.fr/societe/3292355-20220518-securite-france-vraiment-pays-plus-dangereux-europe-non-tel-classement-existe",
        "https://www.20minutes.fr/politique/3291939-20220518-legislatives-2022-quoi-histoire-nuance-politique-nupes-gauche-raison-craindre-entourloupe",
        "https://www.20minutes.fr/sante/3290963-20220517-covid-19-soignants-non-vaccines-reintegres-raison-manque-effectif-non-faux",
        "https://www.20minutes.fr/sante/3291539-20220517-coronavirus-vaccin-pfizer-origine-meforme-rafael-nadal-faux",
        "https://www.20minutes.fr/societe/3291275-20220516-logement-cases-trois-metres-carres-destination-etudiants-17e-arrondissement-prudence",
        "https://www.20minutes.fr/economie/3289743-20220514-bareme-macron-licencier-cdi-cause-reviendrait-moins-cher-payer-prime-precarite-cdd-plus-complique-ca",
        "https://www.20minutes.fr/elections/3288831-20220514-legislatives-2022-faut-desobeir-traites-europeens-pouvoir-mettre-place-cantines-locales-bios"
      ]
      binding.pry
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
