require_relative '../../fetchers/timpul'

describe TimpulFetcher do
  it_behaves_like "a fetcher" do
    let(:fetcher) { subject }

    let(:valid_ids) { %w(98259 98141 73510) }

    let(:invalid_ids) { %w(857438) }
  end
end
