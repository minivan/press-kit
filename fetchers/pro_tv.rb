require_relative "../main"

class ProTvFetcher
  PAGES_DIR  = "data/pages/protv/"
  MAIN_PAGE = "http://protv.md"
  LATEST_NEWS = "http://protv.md/export/featured/json"

  def setup
    FileUtils.mkdir_p PAGES_DIR
  end

  def most_recent_id
    resp = JSON.parse(RestClient.get(LATEST_NEWS))
    resp[0]["id"].to_i
  end

  def latest_stored_id
    Dir["#{PAGES_DIR}*"].map{ |f| f.split('.').first.gsub(PAGES_DIR, "") }
        .map(&:to_i)
        .sort
        .last || 1
  end

  def link(id)
    "#{MAIN_PAGE}/stiri/actualitate/---#{id}.html"
  end

  def save(page, id)
    Zlib::GzipWriter.open(PAGES_DIR + id.to_s + ".html.gz") do |gz|
      gz.write page
    end
  end

  def fetch_single(id)
    page = SmartFetcher.fetch(link(id), false)
    save(page, id) if valid?(page)
  end

  def valid? page
    return unless page

    doc = Nokogiri::HTML(page, nil, 'UTF-8')

    return unless doc.at_css('//h1[@itemprop="name headline"]')

    true
  end

  def progressbar
    @progressbar ||= ProgressBar.new(most_recent_id - latest_stored_id, :bar, :counter, :rate, :eta)
  end

  def run
    setup
    puts "Fetching Protv. Most recent: #{most_recent_id}. Last fetched: #{latest_stored_id}."

    if latest_stored_id == most_recent_id
      puts "Nothing to fetch for Timpul"
      return
    end

    (latest_stored_id..most_recent_id).step(10) do |id|
      fetch_single(id)
      progressbar.increment!
    end
  end
end
