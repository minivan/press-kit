shared_examples "a fetcher" do
  context "connect to the url", :vcr do
    describe "reading the page content" do
      it "#valid" do
        expect(fetcher).to receive(:save).exactly(3).times

        valid_ids.each do |id|
          fetcher.fetch_single(id)
        end
      end

      it "#invalid" do
        expect(fetcher).to receive(:save).exactly(0).times

        invalid_ids.each do |id|
          fetcher.fetch_single(id)
        end
      end
    end
  end
end

shared_examples "a parser" do
  context "reading the data" do
    it "has data" do
      valid_ids.each do |id|
        doc = parser.load_doc(id)
        expect(parser.parse(doc, id)).to_not be nil
      end
    end

    it "does not have data" do
      invalid_ids.each do |id|
        doc = parser.load_doc(id)
        expect(parser.parse(doc, id)).to be nil
      end
    end
  end

  it "finds the article in a page" do
    valid_ids.each do |id|
      doc = parser.load_doc(id)
      expect(parser.parse(doc, id)).to be_kind_of Hash
    end
  end
end