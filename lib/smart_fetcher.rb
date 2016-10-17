# A fetcher that knows how to fetch links properly! FUCK YEAH
class SmartFetcher
  def self.fetch(url)
    RestClient.get url
  rescue Errno::ETIMEDOUT => e
    sleep 2
    puts "timeout: #{url}"
    retry
  rescue Errno::ECONNREFUSED => e
    sleep 30
    puts "refused: #{url}"
    retry
  rescue RestClient::BadGateway => error
    sleep 2
    puts "bad gateway: #{url}"
    retry
  rescue SocketError => error
    puts "socket error: #{url}"
  rescue RestClient::Forbidden => error
    puts "forbidden: #{url}"
    nil
  rescue URI::InvalidURIError => error
    puts "invalid uri: #{url}"
    nil
  rescue RestClient::ResourceNotFound
    puts "not found: #{url}"
    nil
  end
end
