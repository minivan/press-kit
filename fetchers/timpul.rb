require_relative "../main"

module Fetchers
  class Timpul
    include Fetchers::PagesWithIntegerIdInUrl

    MAIN_PAGE = "http://www.timpul.md/"

    def initialize(storage=LocalStorageFactory.timpul)
      @storage = storage
    end

  private

    def fetch_most_recent_id
      doc = Nokogiri::HTML.parse(RestClient.get(MAIN_PAGE))
      hrefs = doc.css("a").map { |link| link["href"] }.compact
      possible_ids = hrefs.map { |href| href.scan(/-([\d]+)\.html/)[0] }.compact
      possible_ids.map { |id| id.first.to_i }.max
    end

    def link(id)
      "http://www.timpul.md/u_#{id}/"
    end

    def fetch_single(id)
      SmartFetcher.fetch(link(id))
    end

    def valid?(page)
      return false unless page
      doc = Nokogiri::HTML(page, nil, "UTF-8")
      return false if doc.title == "Timpul - Ştiri din Moldova"
      return false unless doc.css(".content").size > 0

      true
    end
  end
end
