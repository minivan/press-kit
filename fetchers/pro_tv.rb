require_relative "../main"

module Fetchers
  class ProTv
    include Fetchers::PagesWithIntegerIdInUrl

    MAIN_PAGE = "http://protv.md"
    LATEST_NEWS = "http://protv.md/export/featured/json"

    def initialize(storage=LocalStorageFactory.pro_tv)
      @storage = storage
    end

  private

    def fetch_most_recent_id
      resp = JSON.parse(RestClient.get(LATEST_NEWS))
      resp[0]["id"].to_i
    end

    def link(id)
      "#{MAIN_PAGE}/stiri/actualitate/---#{id}.html"
    end

    def fetch_single(id)
      page = SmartFetcher.fetch(link(id))
      save(page, id) if valid?(page)
    end

    def valid?(page)
      return false if page.nil?

      doc = Nokogiri::HTML(page, nil, "UTF-8")
      !doc.at_css('//h1[@itemprop="name headline"]').nil?
    end
  end
end
