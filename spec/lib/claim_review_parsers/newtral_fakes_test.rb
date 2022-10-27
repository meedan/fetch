# frozen_string_literal: true

describe NewtralFakes do
  describe 'instance' do
    it 'has a hostname' do
      expect(described_class.new.hostname).to(eq('https://www.newtral.es'))
    end

    it 'has a relevant_sitemap_subpath' do
      expect(described_class.new.relevant_sitemap_subpath).to(eq("www.newtral.es/fake"))
    end

    it 'matches urls based on subpath' do
      expect(described_class.new.includes_relevant_path("https://www.newtral.es/fake-sitemap.xml")).to(eq(true))
    end

    it 'gets sitemap urls' do
      described_class.any_instance.stub(:get_url).with("https://www.newtral.es/sitemap_index.xml").and_return(File.read("spec/fixtures/newtral_sitemap_main.xml"))
      response = described_class.new.get_sitemap_urls("https://www.newtral.es/sitemap_index.xml")
      expect(response.class).to(eq(Array))
      expect(response[0].class).to(eq(String))
    end

    it 'gets article urls' do
      described_class.any_instance.stub(:get_url).with("https://www.newtral.es/sitemap_index.xml").and_return(File.read("spec/fixtures/newtral_sitemap_main.xml"))
      described_class.any_instance.stub(:get_url).with("https://www.newtral.es/fake-sitemap.xml").and_return(File.read("spec/fixtures/newtral_sitemap_sub_tree.xml"))
      response = described_class.new.get_article_urls
      expect(response.class).to(eq(Array))
      expect(response[0].class).to(eq(String))
    end

    it 'gets new article urls' do
      described_class.any_instance.stub(:get_url).with("https://www.newtral.es/sitemap_index.xml").and_return(File.read("spec/fixtures/newtral_sitemap_main.xml"))
      described_class.any_instance.stub(:get_url).with("https://www.newtral.es/fake-sitemap.xml").and_return(File.read("spec/fixtures/newtral_sitemap_sub_tree.xml"))
      described_class.any_instance.stub(:get_existing_urls).with(anything).and_return([])
      response = described_class.new.get_new_article_urls
      expect(response.class).to(eq(Array))
      expect(response[0].class).to(eq(String))
    end

    it 'runs get_claim_reviews' do
      described_class.any_instance.stub(:get_url).with("https://www.newtral.es/sitemap_index.xml").and_return(File.read("spec/fixtures/newtral_sitemap_main.xml"))
      described_class.any_instance.stub(:get_url).with("https://www.newtral.es/fake-sitemap.xml").and_return(File.read("spec/fixtures/newtral_sitemap_sub_tree.xml"))
      described_class.any_instance.stub(:get_existing_urls).with(anything).and_return(described_class.new.get_article_urls)
      expect(described_class.new.get_claim_reviews).to(eq([]))
    end

    it 'parses a raw_claim_review' do
      raw = JSON.parse(File.read('spec/fixtures/newtral_fact_check_raw.json'))
      raw['page'] = Nokogiri.parse(raw['page'])
      parsed_claim = described_class.new.parse_raw_claim_review(raw)
      expect(parsed_claim.class).to(eq(Hash))
      ClaimReview.mandatory_fields.each do |field|
        expect(QuietHashie[parsed_claim][field].nil?).to(eq(false))
      end
    end
  end
end