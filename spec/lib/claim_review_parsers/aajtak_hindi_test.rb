# frozen_string_literal: true

describe AajtakHindi do
  describe 'instance' do
    it 'has a hostname' do
      expect(described_class.new.hostname).to(eq('https://www.aajtak.in'))
    end

    it 'has a fact_list_path' do
      expect(described_class.new.fact_list_path(1)).to(eq('/ajax/load-more-special-listing?id=1&type=story/photo_gallery/video/breaking_news&path=/fact-check'))
    end

    it 'has a url_extraction_search' do
      urls = ["https://www.aajtak.in/fact-check/video/fact-check-delhi-pothole-road-shared-as-uttar-pradesh-afwa-viral-news-1331038-2021-09-23", "https://www.aajtak.in/fact-check/story/fact-check-charanjit-singh-channi-oath-ceremony-allah-hu-akbar-slogan-fake-news-ntc-1330816-2021-09-23", "https://www.aajtak.in/fact-check/story/fact-check-viral-post-social-media-hindu-driver-dumped-bus-in-the-river-after-forcibly-feeding-non-veg-to-muslim-processions-afwa-ntc-1330616-2021-09-23", "https://www.aajtak.in/fact-check/video/fact-check-was-punjab-cm-charanjit-singh-channi-a-singer-before-he-joined-politics-1330585-2021-09-22", "https://www.aajtak.in/fact-check/story/fact-check-image-of-pothole-road-from-delhi-goes-viral-as-that-from-up-ntc-1330502-2021-09-22", "https://www.aajtak.in/fact-check/story/fact-check-aimim-chief-asaduddin-owaisi-mai-kattar-hu-statement-viral-false-claim-afwa-1330364-2021-09-22", "https://www.aajtak.in/fact-check/story/fact-check-man-beaten-by-relatives-in-jodhpur-video-went-viral-with-communal-angle-ntc-1330056-2021-09-21", "https://www.aajtak.in/fact-check/story/fact-check-ajmer-sharif-dargah-miracle-fish-shaped-light-viral-video-ntc-1330035-2021-09-21", "https://www.aajtak.in/fact-check/story/fact-check-reet-exam-ashok-gehlot-internet-connection-prohibited-lockdown-ntc-1329984-2021-09-21", "https://www.aajtak.in/fact-check/video/fact-check-of-high-tech-ayodhya-railway-station-ram-mandir-1329969-2021-09-21", "https://www.aajtak.in/fact-check/video/fact-check-of-security-advisor-ajit-doval-pok-survey-tweet-1329905-2021-09-21", "https://www.aajtak.in/fact-check/story/fact-check-social-media-ayodhya-railway-station-old-photo-viral-new-delhi-station-model-ntc-1329606-2021-09-21", "https://www.aajtak.in/fact-check/video/captain-amarinder-meeting-amit-shah-old-picture-viral-with-fake-post-news-in-hindi-1329483-2021-09-20", "https://www.aajtak.in/fact-check/story/fact-check-captain-amrinder-singh-viral-photo-amit-singh-bjp-punjab-social-media-ntc-1329036-2021-09-19", "https://www.aajtak.in/fact-check/video/fact-check-viral-photo-of-road-being-described-as-moon-is-not-of-varanasi-video-1328952-2021-09-19", "https://www.aajtak.in/fact-check/story/fact-check-national-security-advisor-ajit-doval-fake-tweet-viral-social-media-survey-pok-ntc-1328639-2021-09-18", "https://www.aajtak.in/fact-check/video/fact-check-old-isis-video-shared-to-show-brutality-of-taliban-rule-afghanistan-crisis-1328510-2021-09-18", "https://www.aajtak.in/fact-check/story/taliban-isis-viral-video-torturing-fact-check-reality-detail-ntc-1328257-2021-09-18", "https://www.aajtak.in/fact-check/story/fact-check-srinagar-ganpatyar-mandir-31-years-viral-video-false-claim-afwa-1327416-2021-09-16", "https://www.aajtak.in/fact-check/story/fact-check-photos-of-potholed-road-is-not-from-varanasi-ntc-1326698-2021-09-14", "https://www.aajtak.in/fact-check/video/rajasthan-police-officer-with-women-constable-dance-video-is-of-nikita-sharma-1326642-2021-09-14"]
      expect(described_class.new.url_extractor(JSON.parse(File.read("spec/fixtures/aajtak_hindi_index_response.json")))).to(eq(urls))
    end

    it 'parses a raw_claim_review' do
      raw = JSON.parse(File.read('spec/fixtures/aajtak_hindi_raw.json'))
      raw['page'] = Nokogiri.parse(raw['page'])
      parsed_claim = described_class.new.parse_raw_claim_review(raw)
      expect(parsed_claim.class).to(eq(Hash))
      ClaimReview.mandatory_fields.each do |field|
        expect(QuietHashie[parsed_claim][field].nil?).to(eq(false))
      end
    end

  end
end
