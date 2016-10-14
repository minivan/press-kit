require_relative "../main"

class UnimediaParser
  attr_accessor :page_dir, :parsed_data

  def latest_stored_id
    @latest_stored_id = Dir["#{@page_dir}*"].map{ |f| f.split('.').first.gsub(@page_dir, "") }
                        .map(&:to_i)
                        .sort
                        .last || 0
  end

  def latest_parsed_id
    ParsedPage.where(source: 'unimedia').desc(:article_id).limit(1).first.article_id
  rescue
    0
  end

  def load_doc(id)
    Zlib::GzipReader.open("#{@page_dir}#{id}.html.gz") {|gz| gz.read }
  end

  def parse_timestring(timestring)
    # ora: 09:42, 02 mai 2009
    timestring.gsub!("ian", "jan")
    timestring.gsub!("mai", "may")
    timestring.gsub!("iun", "jun")
    timestring.gsub!("iul", "jul")
    timestring.gsub!("noi", "nov")
    return DateTime.strptime(timestring, "ora: %k:%M, %d %b %Y").iso8601
  end

  def build_url(id)
    "http://unimedia.info/stiri/-#{id}.html"
  end

  def parse(text, id)
    doc = Nokogiri::HTML(text, nil, 'UTF-8')
    if doc.title.match(/pagină nu există/) or doc.title.match(/UNIMEDIA - Portalul de știri nr. 1 din Moldova/)
      return
    end

    title = doc.css('h1.bigtitlex2').first.text rescue doc.title
    timestring, views, comments = doc.css('.left-container > .news-details > .white-v-separator').map(&:text)
    content = doc.css('.news-text').text.gsub(/\r|\n/, ' ').squeeze(' ')

    {
      source:         "unimedia",
      title:          title,
      original_time:  timestring,
      datetime:       parse_timestring(timestring),
      views:          views.to_i,
      comments:       comments.to_i,
      content:        content,
      article_id:     id,
      url:            build_url(id)
    }
  rescue => e
    puts "Unimedia: #{e}"
    return
  end

  def save(id, hash)
    puts hash
    page = ParsedPage.new(hash)
    page.save
  end

  def progress(id)
    "#{id}/#{latest_stored_id}"
  end

  def run
    @page_dir = "data/pages/unimedia/"

    (latest_parsed_id..latest_stored_id).to_a.each do |id|
      begin
        puts "\nUnimedia: #{progress(id)}"
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
