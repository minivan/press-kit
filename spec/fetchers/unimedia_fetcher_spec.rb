require_relative '../../fetchers/unimedia'

describe Fetchers::Unimedia do
  it_behaves_like "a fetcher" do
    let(:fetcher) { subject }

    let(:valid_ids) { %w(94985 94998 94983) }

    let(:invalid_ids) { %w(857438) }
  end
end
