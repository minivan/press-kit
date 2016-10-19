describe Fetchers::Agora do 
  it_behaves_like "a fetcher" do
    let(:fetcher) { subject }

    let(:valid_ids) { %w(23575) }

    let(:invalid_ids) { %w(857438) }
  end
end