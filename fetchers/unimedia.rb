require_relative "../main"

class UnimediaFetcher
  PAGES_DIR = "data/pages/unimedia/"
  FEED_URL = "http://unimedia.info/rss/news.xml"

  def setup
    FileUtils.mkdir_p PAGES_DIR
  end

  def most_recent_id
    return @most_recent_id if @most_recent_id
    doc = Nokogiri::XML(RestClient.get(FEED_URL))
    @most_recent_id = doc.css("link")[3].text.scan(/-([\d]+)\.html.+/).first.first.to_i
  end

  def latest_stored_id
    Dir["#{PAGES_DIR}*"].map { |f| f.split('.').first.gsub(PAGES_DIR, "") }
        .map(&:to_i)
        .sort
        .last || 0
  end

  def link(id)
    "http://unimedia.info/stiri/-#{id}.html"
  end

  def save(page, id)
    Zlib::GzipWriter.open(PAGES_DIR + id.to_s + ".html.gz") do |gz|
      gz.write page
    end
  end

  def valid? page
    return false unless page
    doc = Nokogiri::HTML(page, nil, 'UTF-8')
    return false if doc.title.match(/pagină nu există/)
    return false if doc.title.match(/UNIMEDIA - Portalul de știri nr. 1 din Moldova/)
    true
  end

  def fetch_single(id)
    page = SmartFetcher.fetch(link(id))
    save(page, id) if valid?(page)
  rescue RestClient::ResourceNotFound => error
    puts "not found: #{link(id)}"
  end

  def progressbar
    @progressbar ||= ProgressBar.new(most_recent_id - latest_stored_id, :bar, :counter, :rate, :eta)
  end

  def run
    setup
    puts "Fetching Unimedia. Most recent: #{most_recent_id}. Last fetched: #{latest_stored_id}."

    if latest_stored_id == most_recent_id
      puts "Nothing to fetch for Unimedia"
      return
    end

    latest_stored_id.upto(most_recent_id) do |id|
      fetch_single(id)
      progressbar.increment!
    end
  end
end
