# A fetcher that knows how to fetch links properly! FUCK YEAH
class SmartFetcher
  class << self

    def fetch(url)
      execute_fetch(url)
    rescue SocketError
      puts "socket error: #{url}"
    end

    def fetch_with_retry_on_socket_error(url)
      execute_fetch(url)
    rescue SocketError
      puts "socket error: #{url}"
      if retry_on_socket_error
        sleep 60
        puts "retry to fetch after socket error: #{url}"
        retry
      else
        nil
      end
    end

  private

    def execute_fetch(url)
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
    rescue RestClient::Forbidden => error
      puts "forbidden: #{url}"
    rescue URI::InvalidURIError => error
      puts "invalid uri: #{url}"
    rescue RestClient::ResourceNotFound
      puts "not found: #{url}"
    end
  end
end
