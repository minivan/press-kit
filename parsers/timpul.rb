require_relative "../main"

class TimpulParser
  PAGES_DIR       = "data/pages/timpul/"

  def latest_stored_id
    @latest_stored_id = Dir["#{PAGES_DIR}*"].map{ |f| f.split('.').first.gsub(PAGES_DIR, "") }
                        .map(&:to_i)
                        .sort
                        .last || 0
  end

  def latest_parsed_id
    ParsedPage.where(source: 'timpul').desc(:article_id).limit(1).first.article_id
  rescue
    0
  end

  def load_doc(id)
    Zlib::GzipReader.open("#{PAGES_DIR}#{id}.html.gz") {|gz| gz.read }
  end

  def parse_timestring(timestring)
    # 27 Aprilie 2014, ora 08:22
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
    return DateTime.strptime(timestring, "%d %b %Y, ora %k:%M").iso8601
  end

  def sanitize_node!(doc)
    doc.css('.changeFont').css("script").each do |div|
      new_node = doc.create_element "p"
      div.replace new_node
    end
  end

  def build_url(id)
    "http://www.timpul.md/u_#{id}/"
  end

  def parse(text, id)
    doc = Nokogiri::HTML(text, nil, 'UTF-8')

    return if doc.title == "Timpul - Ştiri din Moldova"

    unless doc.css('.content').size > 0
      puts "Timpul: id #{id} - no content"
      return
    end

    title = doc.title.split(" | ").first.strip rescue doc.title
    timestring = doc.css('.box.artGallery').css('.data_author').text.split("\n").map(&:strip)[2]
    sanitize_node!(doc)
    content = doc.css('.changeFont').text.gsub("\n", '').gsub("\t",'').strip

    {
      source:         "timpul",
      title:          title,
      original_time:  timestring,
      datetime:       parse_timestring(timestring),
      views:          0, # No data
      comments:       0, # Disqus iframe
      content:        content,
      article_id:     id.to_i,
      url:            build_url(id)
    }
  end

  def save (id, hash)
    puts "parsed: #{hash}"
    page = ParsedPage.new(hash)
    page.save
  end

  def progress(id)
    total = latest_stored_id - latest_parsed_id
    current = id - latest_parsed_id
    (current / total.to_f * 100).round(2)
  end

  def run
    (latest_parsed_id..latest_stored_id).to_a.each do |id|
      hash = parse(load_doc(id), id)
      puts progress(id).to_s + "% done"

      if hash
        puts "Timpul: id #{id}"
        p hash
        save(id, hash)
      else
        puts "Timpul: id #{id} - no data"
      end
    end
  end
end
