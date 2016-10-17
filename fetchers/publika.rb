require_relative "../main"

class PublikaFetcher
  PAGES_DIR = "data/pages/publika/"
  FEED_URL = "http://rss.publika.md/stiri.xml"

  def initialize(storage=LocalStorageFactory.publika)
    @storage = storage
  end

  def run
    puts "Fetching Publika. Most recent: #{most_recent_id}. Last fetched: #{latest_stored_id}."

    if all_pages_are_fetched?
      puts "Nothing to fetch for Publika"
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

  def ftech_most_recent_id
    doc = Nokogiri::XML(RestClient.get(FEED_URL))
    doc.css("link")[2]
      .text
      .scan(/_([\d]+)\.html/)
      .first
      .first
      .to_i
  end

  def link(id)
    "http://publika.md/#{id}"
  end

  def valid?(page)
    !page.nil? && page.include?("publicat in data de")
  end

  def fetch_single(id)
    page = SmartFetcher.fetch_with_retry_on_socket_error(link(id))
    save(page, id) if valid?(page)
  end

  def progressbar
    @progressbar ||= ProgressBar.new(most_recent_id - latest_stored_id, :bar, :counter, :rate, :eta)
  end
end
