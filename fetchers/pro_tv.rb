require_relative "../main"

class ProTvFetcher
  PAGES_DIR  = "data/pages/protv/"
  MAIN_PAGE = "http://protv.md"
  LATEST_NEWS = "http://protv.md/export/featured/json"

  def initialize(storage=LocalStorage.new)
    storage.setup PAGES_DIR
    @storage = storage
  end

  def run
    puts "Fetching Protv. Most recent: #{most_recent_id}. Last fetched: #{latest_stored_id}."

    if all_pages_are_fetched?
      puts "Nothing to fetch for Timpul"
      return
    end

    (latest_stored_id..most_recent_id).step(10) do |id|
      fetch_single(id)
      progressbar.increment!
    end
  end

private

  def all_pages_are_fetched?
    latest_stored_id == most_recent_id
  end

  def latest_stored_id
    @storage.latest_page_id
  end

  def save(page, id)
    @storage.save(page, id)
  end

  def most_recent_id
    @most_recent_id ||= fetch_most_recent_id
  end

  def fetch_most_recent_id
    resp = JSON.parse(RestClient.get(LATEST_NEWS))
    resp[0]["id"].to_i
  end

  def link(id)
    "#{MAIN_PAGE}/stiri/actualitate/---#{id}.html"
  end

  def fetch_single(id)
    page = SmartFetcher.fetch(link(id), false)
    save(page, id) if valid?(page)
  end

  def valid?(page)
    return false if page.nil?

    doc = Nokogiri::HTML(page, nil, "UTF-8")
    !doc.at_css('//h1[@itemprop="name headline"]').nil?
  end

  def progressbar
    @progressbar ||= ProgressBar.new(most_recent_id - latest_stored_id, :bar, :counter, :rate, :eta)
  end
end
