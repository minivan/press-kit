require_relative '../main'

class RacaiBuilder

  AKUENNE_WORD  = " .pomedor. "
  AKUENNE_RACAI = /\npomedor\t.*\tpomedor/

  def initialize(pages)
    @pages = pages
    @input = pages.map(&:content).join(AKUENNE_WORD).encode("utf-8")
  end

  def tokenize
    @input = client_call(:tokenizer)
    self
  end

  def tag
    @input = client_call(:tagger)
    self
  end

  def lemmatize
    @input = client_call(:lemmatizer)
    self
  end

  def chunk
    @input = client_call(:chunker)
    self
  end

  def to_sgml
    @input = client_call(:utf8to_sgml, nil)
    self
  end

  def to_utf8
    @input = client_call(:sgm_lto_utf8, nil)
    self
  end

  def build
    racai_result = @input.encode("utf-8").split(AKUENNE_RACAI)
    @pages.zip(racai_result)
  end

private
  def client
    @@client ||= Savon.client(read_timeout: 3600, open_timeout: 3600) do
      wsdl "http://ws.racai.ro/ttlws.wsdl"
    end
  end

  def client_call(action, lang="ro")
    message = { input: @input }
    unless lang.nil?
      message = Hash[:lang, "ro"].merge!(message)
    end
    extract_response(client.call(action, message: message), action)
  end

  def extract_response(response, action)
    action = action.to_s
    result = response.body[(action+"_response").to_sym][(action+"_return").to_sym]
    if result.nil?
      return response.hash[(action+"_return").to_sym]
    end
    result
  end
end
