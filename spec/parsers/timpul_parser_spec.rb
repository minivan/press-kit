require_relative '../../parsers/unimedia'

describe TimpulParser do
  it_behaves_like "a parser" do
    let(:parser) { described_class.new }

    let(:valid_ids) { %w(98259 98141 73510) }
    let(:invalid_ids) { %w(10211) }

    before do
      parser.page_dir = 'spec/fixtures/timpul/'
    end
  end
end
