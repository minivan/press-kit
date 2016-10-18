require_relative '../../parsers/publika'

describe PublikaParser do
  include_context :db

  let(:parser) { described_class.new }
  let(:valid_ids) { %w(10211) }
  let(:invalid_ids) { %w(15) }

  before do
    parser.page_dir = 'spec/fixtures/publika/'
  end

  it_behaves_like "a parser"

  it "saves to the database" do
    doc = parser.load_doc(valid_ids[0])
    hash = parser.parse(doc, valid_ids[0])
    parser.save(hash)

    expect(ParsedPage.where(source: "publika", article_id: valid_ids[0])).not_to be nil
  end
end
