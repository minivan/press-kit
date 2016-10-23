module Parsers
  class Agora
    include Strategy::Incremental
    include Helpers::SanitizeDates
    attr_reader :url, :storage, :source

    def initialize(storage: LocalStorageFactory.agora, url: URL::Agora.new)
      @storage = storage
      @url = url
      @source = "agora"
    end

    def parse(html, id)
      doc = Nokogiri::HTML(html, nil, "UTF-8")

      date_time = extract_date_time(doc)
      title = doc.css("h1.post-title").text.strip
      views = doc.css("ul.entry-meta.post-meta li:nth-child(3)").text.strip.to_i rescue 0
      content = extract_content(doc)
      binding.pry
      {
        source: source,
        title: title,
        original_time: date_time,
        datetime: parse_timestring(date_time),
        views: views,
        comments: 0, # Facebook iframe
        content: content,
        article_id: id,
        url: build_url(id)
      }
    end

    def extract_content(doc)
      content_doc = doc.css(".post-content")
      content_doc.search("//script").remove
      content_doc.text.strip
    end

    def extract_date_time(doc)
      date = doc.css("ul.entry-meta.post-meta li:nth-child(1)").text.strip
      time = doc.css("ul.entry-meta.post-meta li:nth-child(2)").text.strip
      date + " " + time
    end

    def parse_timestring(timestring)
      sanitized_timestring = months_ro_to_en(timestring)
      DateTime.strptime(sanitized_timestring , "%d %b %Y %k:%M").iso8601
    end
  end
end
