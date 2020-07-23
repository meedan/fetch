# frozen_string_literal: true

describe Site do
  describe 'endpoints' do
    it 'returns an empty GET claim_reviews.json response' do
      ClaimReview.stub(:search).with({:offset=>0, :per_page=>20}).and_return([])
      code, headers, body = described_class.call(
        'REQUEST_METHOD' => 'GET',
        'PATH_INFO' => '/claim_reviews.json',
        'rack.input' => StringIO.new
      )
      expect(code).to(eq(200))
      expect(JSON.parse(body[0])).to(eq([]))
    end

    it 'returns a non-empty GET claim_reviews.json response' do
      ClaimReview.stub(:search).with({:offset=>0, :per_page=>20}).and_return([{ bloop: 1 }])
      code, headers, body = described_class.call(
        'REQUEST_METHOD' => 'GET',
        'PATH_INFO' => '/claim_reviews.json',
        'rack.input' => StringIO.new
      )
      expect(code).to(eq(200))
      expect(JSON.parse(body[0])).to(eq([{ 'bloop' => 1 }]))
    end

    it 'returns an about page' do
      code, headers, body = described_class.call(
        'REQUEST_METHOD' => 'GET',
        'PATH_INFO' => '/about',
        'rack.input' => StringIO.new
      )
      expect(code).to(eq(200))
      expect(JSON.parse(body[0]).class).to(eq(Hash))
    end

    it 'returns a services page' do
      Elasticsearch::Transport::Client.any_instance.stub(:search).with(anything()).and_return({"took"=>21, "timed_out"=>false, "_shards"=>{"total"=>1, "successful"=>1, "skipped"=>0, "failed"=>0}, "hits"=>{"total"=>14055, "max_score"=>2.1063054, "hits"=>[{"_index"=>"claim_reviews", "_type"=>"claim_review", "_id"=>"0f6a429f5a4e6d017b152665f9cdcadc"}]}})
      code, headers, body = described_class.call(
        'REQUEST_METHOD' => 'GET',
        'PATH_INFO' => '/services',
        'rack.input' => StringIO.new
      )
      expect(code).to(eq(200))
      expect(JSON.parse(body[0]).class).to(eq(Hash))
    end
  end
end
