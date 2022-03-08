# frozen_string_literal: true

describe VeraFilesFilipino do
  describe 'instance' do
    it 'has a fact_list_path' do
      expect(described_class.new.fact_list_path(1)).to(eq('/specials/fact-check-filipino?ccm_paging_p=1'))
    end
  end
end
