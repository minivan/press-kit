require_relative "../main"

class AgoraFetcher
  PAGES_DIR = "data/pages/agora/"
  FEED_URL  = "http://agora.md/rss/news"

  def setup
  end

  def most_recent_id
    @most_recent_id ||= fetch_the_most_recent_id
  end

private

  def fetch_the_most_recent_id
    RestClient.get(FEED_URL)
      .match(/http:\/\/agora.md\/stiri\/(\d*)\//)
      .captures
      .first
      .to_i rescue 0
  end
end
