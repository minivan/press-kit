module Parsers
  class Publika
    include Strategy::Incremental
    attr_reader :url, :storage, :source

    def initialize(storage: LocalStorageFactory.publika, url: URL::Publika.new)
      @storage = storage
      @url = url
      @source = "publika"
    end

    def parse(text, id)
      doc = Nokogiri::HTML(text, nil, "UTF-8")

      return unless has_data?(doc)

      title = doc.xpath("//div[@id='articleLeftColumn']/h1").text
      article_info = doc.xpath("//div[@class='articleInfo']").text.split(', ')
      date = article_info[2]
      ora = article_info[3][0..9]

      content = doc.xpath("//div[@itemprop='articleBody']").text

      {
          source:         source,
          title:          title,
          original_time: "Date: #{date} Time: #{ora}",
          datetime:       parse_timestring(date.concat(ora)),
          views:          0,
          comments:       0,
          content:        content,
          article_id:     id,
          url:            build_url(id)
      }
    rescue => e
      puts "Publika: #{e}"
    end

    def has_data?(doc)
      doc.xpath("//div[@class='articleTags']").any?
    end

    def parse_timestring(timestring)
      # ora: 09:42, 02 mai 2009
      timestring.gsub!("Aprilie",    "apr")
      timestring.gsub!("Mai",        "may")
      timestring.gsub!("Iunie",      "jun")
      timestring.gsub!("Iulie",      "jul")
      timestring.gsub!("August",     "aug")
      timestring.gsub!("Septembrie", "sep")
      timestring.gsub!("Octombrie",  "oct")
      timestring.gsub!("Noiembrie",  "nov")
      timestring.gsub!("Decembrie",  "dec")
      timestring.gsub!("Ianuarie",   "jan")
      timestring.gsub!("Februarie",  "feb")
      timestring.gsub!("Martie",     "mar")
      DateTime.strptime(timestring, "%d %b %Y ora %k:%M").iso8601
    end
  end
end
