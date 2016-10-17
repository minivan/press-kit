require_relative "../main"

class UnimediaFetcher
  PAGES_DIR = "data/pages/unimedia/"
  FEED_URL = "http://unimedia.info/rss/news.xml"

  def initialize(storage=LocalStorage.new)
    storage.setup PAGES_DIR
    @storage = storage
  end

  def run
    puts "Fetching Unimedia. Most recent: #{most_recent_id}. Last fetched: #{latest_stored_id}."

    if all_pages_are_fetched?
      puts "Nothing to fetch for Unimedia"
      return
    end

    latest_stored_id.upto(most_recent_id) do |id|
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

  def ftech_most_recent_id
    doc = Nokogiri::XML(RestClient.get(FEED_URL))
    doc.css("link")[3].text.scan(/-([\d]+)\.html.+/).first.first.to_i
  end

  def link(id)
    "http://unimedia.info/stiri/-#{id}.html"
  end

  def valid?(page)
    return false unless page
    doc = Nokogiri::HTML(page, nil, 'UTF-8')
    return false if doc.title.match(/pagină nu există/)
    return false if doc.title.match(/UNIMEDIA - Portalul de știri nr. 1 din Moldova/)
    true
  end

  def fetch_single(id)
    page = SmartFetcher.fetch_with_retry_on_socket_error(link(id))
    save(page, id) if valid?(page)
  end

  def progressbar
    @progressbar ||= ProgressBar.new(most_recent_id - latest_stored_id, :bar, :counter, :rate, :eta)
  end
end
