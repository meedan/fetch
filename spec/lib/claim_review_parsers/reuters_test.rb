# frozen_string_literal: true

describe Reuters do
  describe 'instance' do
    it 'has a hostname' do
      expect(described_class.new.hostname).to(eq('https://www.reuters.com'))
    end

    it 'has a fact_list_path' do
      expect(described_class.new.fact_list_path(1)).to(eq('/news/archive/reuterscomservice?view=page&page=1&pageSize=10'))
    end

    it 'extracts a url' do
      expect(described_class.new.url_extractor(Nokogiri.parse("<a href='/blah'>wow</a>").search('a')[0])).to(eq('https://www.reuters.com/blah'))
    end

    it 'finds claim_result_from_page' do
      expect(described_class.new.claim_result_from_page(Nokogiri.parse("<html><div class=\"article-body__content__17Yit\"><h2 data-testid=\"Heading\" class=\"text__text__1FZLe text__dark-grey__3Ml43 text__medium__1kbOh text__heading_6__1qUJ5 heading__base__2T28j heading__heading_6__RtD9P article-body__heading__33EIm\">VEREDICTO</h2><p data-testid=\"paragraph-13\" class=\"text__text__1FZLe text__dark-grey__3Ml43 text__regular__2N1Xr text__small__1kGq2 body__full_width__ekUdw body__small_body__2vQyf article-body__paragraph__2-BtD\">Alterado digitalmente. O post usa um trecho do Jornal Hoje adulterado para forjar a notícia de um falso projeto da Friboi com o governo federal para distribuição de kits churrasco.</p></div></html>"))).to(eq('Alterado digitalmente'))
    end

    it 'parses a raw_claim_review' do
      raw = JSON.parse(File.read('spec/fixtures/reuters_raw.json'))
      raw['page'] = Nokogiri.parse(raw['page'])
      parsed_claim = described_class.new.parse_raw_claim_review(raw)
      expect(parsed_claim.class).to(eq(Hash))
      ClaimReview.mandatory_fields.each do |field|
        expect(QuietHashie[parsed_claim][field].nil?).to(eq(false))
      end
    end
  end
end
