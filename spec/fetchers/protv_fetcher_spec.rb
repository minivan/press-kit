require_relative '../../fetchers/pro_tv'

describe Fetchers::ProTv do
  let(:fetcher) { subject }

  it_behaves_like "a fetcher" do

    let(:valid_ids) { %w(1637231 1637721 1637711) }

    let(:invalid_ids) { %w(90) }
  end

  context "latest article", :vcr do
    it "gets the latest stored id" do
      expect(fetcher.most_recent_id).to be_kind_of Fixnum
    end
  end
end
