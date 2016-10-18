require_relative "../main"

module Fetchers
  class Agora
    FEED_URL  = "http://agora.md/rss/news"

    def initialize(storage=LocalStorageFactory.agora)
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

    def fetch_most_recent_id
      RestClient.get(FEED_URL)
        .match(/http:\/\/agora.md\/stiri\/(\d*)\//)
        .captures
        .first
        .to_i
    end

    def link(id)
      "http://agora.md/stiri/#{id}/"
    end

    def valid?(page)
      doc = Nokogiri::HTML(page, nil, "UTF-8")
      doc.title != "Agora - 404"
    end

    def fetch_single(id)
      page = SmartFetcher.fetch(link(id))
      save(page, id) if valid?(page)
    end

    def progressbar
      @progressbar ||= ProgressBar.new(most_recent_id - latest_stored_id, :bar, :counter, :rate, :eta)
    end
  end
end
