module Fetchers
  class Prime
    include Strategy::Incremental
    attr_reader :url, :storage

    def initialize(storage: LocalStorageFactory.prime, url: URL::Prime.new)
      @storage = storage
      @url = url
    end

    def run
      puts "Fetching Prime"
			if all_pages_are_fetched?
				puts "Nothing to fetch for Prime"
				return
			end

			page_ids.each do |id|
        page_and_category = fetch_single(id)
      end
    end

    def fetch_single(id)
      page_and_categories = url.all_possible
    end

    def most_recent_id
      @most_recent_id ||= fetch_most_recent_id
    end

    def fetch_most_recent_id
      doc = Nokogiri::HTML(RestClient.get(url.main_news_page))
      first_news_url = doc.css(".left_column .news_rubric_item:first a:first").attribute("href")
      first_news_url.match(/\/item(\d+)\//).captures.first.to_i
    end

    def page_ids
      latest_stored_id.upto(most_recent_id)
    end
  end
end
