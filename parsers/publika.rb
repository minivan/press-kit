require_relative "../main"

class PublikaParser
  attr_accessor :page_dir, :parsed_data

  def latest_stored_id
    @latest_stored_id = Dir["#{@page_dir}*"].map{ |f| f.split('.').first.gsub(@page_dir, "") }
                            .map(&:to_i)
                            .sort
                            .last || 0
  end

  def latest_parsed_id
    ParsedPage.where(source: 'publika').desc(:article_id).limit(1).first.article_id
  rescue
    0
  end

  def load_doc(id)
    Zlib::GzipReader.open("#{@page_dir}#{id}.html.gz") {|gz| gz.read }
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

  def build_url(id)
    "http://publika.md/#{id}"
  end

  def has_data?(doc)
    doc.xpath("//div[@class='articleTags']").any?
  end

  def parse(text, id)
    doc = Nokogiri::HTML(text, nil, 'UTF-8')

    return unless has_data?(doc)

    title = doc.xpath("//div[@id='articleLeftColumn']/h1").text
    article_info = doc.xpath("//div[@class='articleInfo']").text.split(', ')
    date = article_info[2]
    ora = article_info[3][0..9]

    # this xpath parses the data from one tag to another. Fetching just the text

    # content = doc.xpath("//*[preceding-sibling::div[@style='clear: both; height: 10px;'] and following-sibling::div[@class='box-share clearfix']]")
    #               .css("p").text

    content = doc.xpath("//div[@itemprop='articleBody']").text

    {
        source:         "publika",
        title:          title,
        original_time: "Date: #{date} Time: #{ora}",
        datetime:       parse_timestring(date.concat ora),
        views:          0,
        comments:       0,
        content:        content,
        article_id:     id,
        url:            build_url(id)
    }
  rescue => e
    puts "Publika: #{e}"
    return
  end

  def save hash
    page = ParsedPage.new(hash)
    page.save
  end

  def progress(id)
    "#{id}/#{latest_stored_id}"
  end

  def run
    @page_dir = "data/pages/publika/"

    (latest_parsed_id..latest_stored_id).to_a.each do |id|
      begin
        puts "\nPublika: #{progress(id)}"

        hash = parse(load_doc(id), id)

        puts hash

        hash ? save(hash) : puts("NO DATA")

        puts "SUCCES"

      rescue Errno::ENOENT => err
        puts "NOT SAVED TO DISK #{err}"
      end
    end
  end
end
