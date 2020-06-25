describe ElasticSearchQuery do
  describe 'class' do
    it 'expects base_query hash' do
      expect(ElasticSearchQuery.base_query(0,0)).to eq({:size=>0, :from=>0, :query=>{:bool=>{:must=>[{:match_all=>{}}], :filter=>[], :should=>[], :must_not=>[]}}})
    end

    it 'expects query_match_clause hash' do
      expect(ElasticSearchQuery.query_match_clause("foo", "val")).to eq({:match_phrase=>{"foo"=>"val"}})
    end

    it 'expects multi_match_query hash' do
      expect(ElasticSearchQuery.multi_match_query("foo", ["val"])).to eq({:bool=>{:should=>[{:match_phrase=>{"foo"=>"val"}}], :minimum_should_match=>1}})
    end

    it 'expects start_end_date_range hash' do
      t = Time.parse("2020-01-01").to_s
      expect(ElasticSearchQuery.start_end_date_range("foo", t, t)).to eq({:range=>{"foo"=>{:format=>"strict_date_optional_time", :gte=>"2020-01-01T00:00:00.000Z", :lte=>"2020-01-01T00:00:00.000Z"}}})
    end

    it 'expects multi_match_against_service hash' do
      expect(ElasticSearchQuery.multi_match_against_service(["one", "two"], "ball", "google")).to eq({:size=>2, :from=>0, :query=>{:bool=>{:must=>[{:match_all=>{}}], :filter=>[{:match_phrase=>{"service"=>"google"}}, {:bool=>{:should=>[{:match_phrase=>{"ball"=>"one"}}, {:match_phrase=>{"ball"=>"two"}}], :minimum_should_match=>1}}], :should=>[], :must_not=>[]}}})
    end

    it 'expects claim_review_search_query hash, full params' do
      t = Time.parse("2020-01-01").to_s
      expect(ElasticSearchQuery.claim_review_search_query("blah", "google", t, t, 20, 0)).to eq({:size=>20,
        :from=>0,
        :query=>
        {:bool=>
        {:must=>[{:match_all=>{}}],
        :filter=>[{:match_phrase=>{"service"=>"google"}}, {:match_phrase=>{"claim_headline"=>"blah"}}, {:range=>{"created_at"=>{:format=>"strict_date_optional_time", :gte=>"2020-01-01T00:00:00.000Z", :lte=>"2020-01-01T00:00:00.000Z"}}}],
        :should=>[],
        :must_not=>[]}}}
      )
    end

    it 'expects claim_review_search_query hash, empty params' do
      expect(ElasticSearchQuery.claim_review_search_query).to eq({:size=>20, :from=>0, :query=>{:bool=>{:must=>[{:match_all=>{}}], :filter=>[], :should=>[], :must_not=>[]}}})
    end

    it 'expects claim_review_search_query hash, empty single time' do
      t = Time.parse("2020-01-01").to_s
      expect(ElasticSearchQuery.claim_review_search_query(nil, "google", nil, t)).to eq({:size=>20, :from=>0, :query=>{:bool=>{:must=>[{:match_all=>{}}], :filter=>[{:match_phrase=>{"service"=>"google"}}, {:range=>{"created_at"=>{:format=>"strict_date_optional_time", :lte=>"2020-01-01T00:00:00.000Z"}}}], :should=>[], :must_not=>[]}}})
    end
  end
end