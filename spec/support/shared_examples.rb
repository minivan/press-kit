shared_examples "a fetcher" do
  context "connect to the url", :vcr do
    describe "reading the page content" do
      before do
        stub = double("increment!" => nil)
        allow(fetcher).to receive(:progressbar).and_return(stub)
      end

      it "is valid" do
        allow(fetcher).to receive(:page_ids).and_return(valid_ids)
        expect(fetcher).to receive(:save).exactly(valid_ids.size).times
        fetcher.run
      end

      it "is invalid" do
        allow(fetcher).to receive(:page_ids).and_return(invalid_ids)
        expect(fetcher).to receive(:save).exactly(0).times
        fetcher.run
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
