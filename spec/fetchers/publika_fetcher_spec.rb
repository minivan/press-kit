require_relative '../../fetchers/publika'

describe Fetchers::Publika do
  let(:fetcher) { subject }

  it_behaves_like "a fetcher" do

    let(:valid_ids) { %w(2699211 2700361 2755861) }

    let(:invalid_ids) { %w(90) }
  end

  context "latest article", :vcr do
    it "gets the latest stored id" do
      expect(fetcher.most_recent_id).to be_kind_of Fixnum
    end
  end
end
