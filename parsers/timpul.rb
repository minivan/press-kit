require_relative "../main"

class TimpulParser
  attr_accessor :page_dir, :parsed_data

  def latest_stored_id
    @latest_stored_id = Dir["#{page_dir}*"].map{ |f| f.split('.').first.gsub(page_dir, "") }
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
    Zlib::GzipReader.open("#{page_dir}#{id}.html.gz") {|gz| gz.read }
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

    unless content.size > 0
      puts "Timpul: id #{id} - empty content"
      return
    end

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
    puts hash
    page = ParsedPage.new(hash)
    page.save
  end

  def progress(id)
    "#{id}/#{latest_stored_id}"
  end

  def run
    @page_dir  = "data/pages/timpul/"

    (latest_parsed_id+1..latest_stored_id).to_a.each do |id|
      begin
        puts "\nTimpul: #{progress(id)}"
        hash = parse(load_doc(id), id)

        if hash
          save(id, hash)
        else
          puts "NO DATA"
        end
      rescue Errno::ENOENT => err
        puts "NOT SAVED TO DISK"
      end
    end
  end
end
