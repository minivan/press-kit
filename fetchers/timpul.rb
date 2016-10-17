require_relative "../main"

class TimpulFetcher
  MAIN_PAGE = "http://www.timpul.md/"

  def initialize(storage=LocalStorageFactory.timpul)
    @storage = storage
  end

  def run
    puts "Fetching Timpul. Most recent: #{most_recent_id}. Last fetched: #{latest_stored_id}."

    if all_pages_are_fetched?
      puts "Nothing to fetch for Timpul"
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
    doc = Nokogiri::HTML.parse(RestClient.get(MAIN_PAGE))
    hrefs = doc.css("a").map { |link| link["href"] }.compact
    possible_ids = hrefs.map { |href| href.scan(/-([\d]+)\.html/)[0] }.compact
    possible_ids.map { |id| id.first.to_i }.max
  end

  def link(id)
    "http://www.timpul.md/u_#{id}/"
  end

  def fetch_single(id)
    page = SmartFetcher.fetch(link(id))
    save(page, id) if valid?(page)
  end

  def valid?(page)
    return unless page
    doc = Nokogiri::HTML(page, nil, "UTF-8")
    return false if doc.title == "Timpul - Ştiri din Moldova"
    return false unless doc.css(".content").size > 0

    true
  end

  def progressbar
    @progressbar ||= ProgressBar.new(most_recent_id - latest_stored_id, :bar, :counter, :rate, :eta)
  end
end
