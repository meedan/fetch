# frozen_string_literal: true

describe CheckForStaleParsers do
  describe 'instance' do
    it 'responds to perform' do
      API.stub(:services).and_return({services: [{:service=>"lupa", :count=>6889, :earliest=>"2018-01-16", :latest=>(Time.now-60*60*24*10).strftime("%Y-%m-%d")}, {:service=>"other_parser", :count=>6889, :earliest=>"2018-01-16", :latest=>(Time.now-60*60*24*1).strftime("%Y-%m-%d")}]})
      response = described_class.new.perform
      expect(response).to(eq(["lupa"]))
    end
  end
end
