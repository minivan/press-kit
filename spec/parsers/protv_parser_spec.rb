describe Parsers::ProTv do
  let(:storage) { LocalStorage.new("spec/fixtures/protv/") }
  let(:valid_ids) { %w(126971 126981 126991) }
  let(:invalid_ids) { %w(727) }

  it_behaves_like "a parser"
end
