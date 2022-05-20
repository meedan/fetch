# frozen_string_literal: true
describe TwentyMinutes do
  before do
    stub_request(:get, "https://www.20minutes.fr/societe/desintox/").
      with(
        headers: {
    	  'Accept'=>'*/*',
    	  'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
    	  'Host'=>'www.20minutes.fr',
    	  'User-Agent'=>/.*/
        }).
      to_return(status: 200, body: File.read("spec/fixtures/twenty_minutes_first_page_raw.html"), headers: {})
    stub_request(:get, "https://www.20minutes.fr/v-ajax/tag/38000456/10").
      with(
        headers: {
    	  'Accept'=>'*/*',
    	  'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
    	  'Host'=>'www.20minutes.fr',
    	  'User-Agent'=>/.*/
        }).
      to_return(status: 200, body: File.read("spec/fixtures/twenty_minutes_raw_index.json"), headers: {})
  end

  describe 'instance' do
    it 'has a hostname' do
      expect(described_class.new.hostname).to(eq('https://www.20minutes.fr'))
    end

    it 'get_new_fact_page_urls(page) from first page' do
      ClaimReview.stub(:existing_urls).with(anything, described_class.service).and_return([])
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
      expect(described_class.new.get_new_fact_page_urls(1)).to(eq(urls))
    end

    it 'get_new_fact_page_urls(page) from not first page' do
      ClaimReview.stub(:existing_urls).with(anything, described_class.service).and_return([])
      urls = [
        "https://www.20minutes.fr/sante/3282103-20220503-coronavirus-deputes-allemands-menaces-poursuite-vaccination-pourquoi-faux",
        "https://www.20minutes.fr/monde/3279143-20220501-conflit-israelo-palestinien-sait-heurts-produits-interieur-mosquee-al-aqsa-jerusalem",
        "https://www.20minutes.fr/politique/3280011-20220430-legislatives-2022-jean-luc-melenchon-patrimoine-2465000-euros-gare-intox",
        "https://www.20minutes.fr/planete/3279523-20220428-non-video-virale-montre-lune-gigantesque-pole-nord",
        "https://www.20minutes.fr/elections/3278627-20220428-legislatives-2022-europe-carte-fin-ue-comme-dit-yannick-jadot",
        "https://www.20minutes.fr/elections/3278251-20220427-presidentielle-2022-comment-resultats-tombent-20h-peuvent-etre-presque-exacts",
        "https://www.20minutes.fr/monde/3278575-20220427-guerre-ukraine-non-photo-montre-inna-shevchenko-figure-femen-faisant-salut-nazi",
        "https://www.20minutes.fr/societe/3276055-20220426-non-etrangers-jamais-travaille-france-droit-1157-euros-retraite",
        "https://www.20minutes.fr/elections/3277091-20220425-resultats-presidentielle-2022-marine-pen-perdu-voix-non-agit-bug-informatique-france-2",
        "https://www.20minutes.fr/elections/presidentielle/3277139-20220425-resultats-presidentielle-2022-marine-pen-felicite-emmanuel-macron-publiquement-entorse-tradition-republicaine"
      ]
      expect(described_class.new.get_new_fact_page_urls(2)).to(eq(urls))
    end

    it 'has a fact_list_path' do
      expect(described_class.new.fact_list_path(1)).to(eq("/societe/desintox/"))
      expect(described_class.new.fact_list_path(2)).to(eq("/v-ajax/tag/38000456/10"))
      expect(described_class.new.fact_list_path(3)).to(eq("/v-ajax/tag/38000456/19"))
    end

    it 'extracts a url from API' do
      expect(described_class.new.url_extractor({"contents" => [{"content" => "<html><body><a href='/blah'>blah</a></body></html>"}]})).to(eq(["/blah"]))
    end

    it 'extracts a url from website' do
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
      expect(described_class.new.url_extractor(Nokogiri.parse(File.read("spec/fixtures/twenty_minutes_first_page_raw.html")))).to(eq(urls))
    end

    it 'parses a raw_claim_review' do
      # twenty_minutes_claim_review_page.json
      raw = JSON.parse(File.read('spec/fixtures/twenty_minutes_raw.json'))
      raw['page'] = Nokogiri.parse(raw['page'])
      parsed_claim = described_class.new.parse_raw_claim_review(raw)
      expect(parsed_claim.class).to(eq(Hash))
      ClaimReview.mandatory_fields.each do |field|
        expect(QuietHashie[parsed_claim][field].nil?).to(eq(false))
      end
    end
  end
end
