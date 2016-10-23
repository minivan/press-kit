describe Parsers::Unimedia do
  let(:storage) { LocalStorage.new("spec/fixtures/unimedia/") }
  let(:valid_ids) { %w(73110) }
  let(:invalid_ids) { %w(10211) }

  it_behaves_like "a parser"
end
