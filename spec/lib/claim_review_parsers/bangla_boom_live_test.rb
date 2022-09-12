# frozen_string_literal: true

describe BanglaBoomLive do
  describe 'instance' do
    it 'has a hostname' do
      expect(described_class.new.hostname).to(eq('http://bangla.boomlive.in'))
    end

    it 'has a fact_list_path' do
      expect(described_class.new.fact_list_path(1)).to(eq('/fact-check/1'))
    end

    it 'has a url_extraction_search' do
      expect(described_class.new.url_extraction_search).to(eq('main#main div.category-articles-list h2.entry-title a'))
    end

    it 'extracts a url' do
      expect(described_class.new.url_extractor(Nokogiri.parse("<a href='/blah'>wow</a>").search('a')[0])).to(eq('http://bangla.boomlive.in/blah'))
    end
    
    it 'extracts author from array' do
      article = {"author"=>
        [{"@type"=>"Person", "name"=>"Sista Mukherjee", "url"=>"https://bangla.boomlive.in/author-sista", "jobTitle"=>"Editor", "image"=>"https://bangla.boomlive.in/h-upload/2022/07/14/981312-sista-new.webp", "sameAs"=>[]},
         {"@type"=>"Person", "name"=>"Srijit Das", "url"=>"https://bangla.boomlive.in/srijit-das", "jobTitle"=>"Editor", "image"=>"https://bangla.boomlive.in/h-upload/2022/07/14/981312-sista-new.webp", "sameAs"=>["https://www.twitter.com/srijitofficial"]}]}
      expect(described_class.new.get_author_and_link_from_article(article).to(eq(["Sista Mukherjee", "http://bangla.boomlive.inhttps://bangla.boomlive.in/author-sista"]))
    end

    it 'gracefully nils on bad article author' do
      article = {"author"=>"blah"}
      expect(described_class.new.get_author_and_link_from_article(article).to(eq([nil,nil]))
    end

    it 'parses a raw_claim_review' do
      raw = JSON.parse(File.read('spec/fixtures/bangla_boom_live_raw.json'))
      raw['page'] = Nokogiri.parse(raw['page'])
      parsed_claim = described_class.new.parse_raw_claim_review(raw)
      expect(parsed_claim.class).to(eq(Hash))
      ClaimReview.mandatory_fields.each do |field|
        expect(QuietHashie[parsed_claim][field].nil?).to(eq(false))
      end
    end
  end
end