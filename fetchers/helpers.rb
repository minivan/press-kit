module Fetchers
  module PagesWithIntegerIdsInUrl
    def run
      puts "Fetching #{self.class.name}. Most recent: #{most_recent_id}. Last fetched: #{latest_stored_id}."

      if all_pages_are_fetched?
        puts "Nothing to fetch for Timpul"
        return
      end

      latest_stored_id.upto(most_recent_id) do |id|
        fetch_single(id)
        progressbar.increment!
      end
    end

    def all_pages_are_fetched?
      latest_stored_id == most_recent_id
    end

    def latest_stored_id
      @storage.latest_page_id
    end

    def save(page, id)
      @storage.save(page, id) if valid?(page)
    end

    def most_recent_id
      @most_recent_id ||= fetch_most_recent_id
    end

    def progressbar
      @progressbar ||= ProgressBar.new(most_recent_id - latest_stored_id, :bar, :counter, :rate, :eta)
    end
  end
end
