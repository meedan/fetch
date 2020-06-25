# frozen_string_literal: true

describe Reuters do
  describe 'instance' do
    it 'has a hostname' do
      expect(Reuters.new.hostname).to eq('https://www.reuters.com')
    end

    it 'has a fact_list_path' do
      expect(Reuters.new.fact_list_path(1)).to eq('/news/archive/reuterscomservice?view=page&page=1&pageSize=10')
    end

    it 'has a url_extraction_search' do
      expect(Reuters.new.url_extraction_search).to eq('div.column1 section.module-content article.story div.story-content a')
    end

    it 'extracts a url' do
      expect(Reuters.new.url_extractor(Nokogiri.parse("<a href='/blah'>wow</a>").search('a')[0])).to eq('https://www.reuters.com/blah')
    end

    it 'parses a raw_claim' do
      raw = JSON.parse(File.read('spec/fixtures/reuters_raw.json'))
      raw['page'] = Nokogiri.parse(raw['page'])
      parsed_claim = Reuters.new.parse_raw_claim(raw)
      expect(parsed_claim.class).to eq(Hash)
      ClaimReview.mandatory_fields.each do |field|
        expect(Hashie::Mash[parsed_claim][field].nil?).to eq(false)
      end
    end
  end
end
