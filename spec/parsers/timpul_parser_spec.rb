describe Parsers::Timpul do
  let(:storage) { LocalStorage.new("spec/fixtures/timpul/") }
  let(:valid_ids) { %w(98259 98141 73510) }
  let(:invalid_ids) { %w(10211) }

  it_behaves_like "a parser"
end
