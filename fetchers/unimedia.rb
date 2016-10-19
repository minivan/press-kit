require_relative "../main"

module Fetchers
  class Unimedia
    include Fetchers::IncrementalStrategy

    FEED_URL = "http://unimedia.info/rss/news.xml"

    def initialize(storage=LocalStorageFactory.unimedia)
      @storage = storage
    end

  private

    def fetch_most_recent_id
      doc = Nokogiri::XML(RestClient.get(FEED_URL))
      doc.css("link")[3].text.scan(/-([\d]+)\.html.+/).first.first.to_i
    end

    def link(id)
      "http://unimedia.info/stiri/-#{id}.html"
    end

    def fetch_single(id)
      SmartFetcher.fetch_with_retry_on_socket_error(link(id))
    end

    def valid?(page)
      return false if page.nil?
      doc = Nokogiri::HTML(page, nil, "UTF-8")
      return false if doc.title.match(/pagină nu există/)
      return false if doc.title.match(/UNIMEDIA - Portalul de știri nr. 1 din Moldova/)
      true
    end

    def page_ids
      latest_stored_id.upto(most_recent_id)
    end
  end
end
