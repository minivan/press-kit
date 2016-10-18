require_relative "../main"

module Fetchers
  class Publika
    include Fetchers::IncrementalStrategy

    PAGES_DIR = "data/pages/publika/"
    FEED_URL = "http://rss.publika.md/stiri.xml"

    def initialize(storage=LocalStorageFactory.publika)
      @storage = storage
    end

  private

    def fetch_most_recent_id
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

    def fetch_single(id)
      SmartFetcher.fetch_with_retry_on_socket_error(link(id))
    end

    def valid?(page)
      !page.nil? && page.include?("publicat in data de")
    end

    def page_ids
      start = if latest_stored_id == 0 then 1 else latest_stored_id end
      (start..most_recent_id).step(10)
    end
  end
end
