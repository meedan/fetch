# frozen_string_literal: true

describe CheckForStaleParsers do
  describe 'instance' do
    it 'responds to perform' do
      API.stub(:services).and_return({services: [{:service=>"tempo_cekfakta", :count=>6889, :earliest=>"2018-01-16", :latest=>(Time.now-60*60*24*10).strftime("%Y-%m-%d")}]})
      response = described_class.new.perform('blah', {})
      expect(response).to(eq(["tempo_cekfakta"]))
    end
  end
end
