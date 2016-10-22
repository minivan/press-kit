module URL
  class ProTv
    attr_reader :base

    def initialize
      @base = "http://protv.md"
    end

    def build(id)
      "#{base}/stiri/actualitate/---#{id}.html"
    end
  end

  class Agora
    attr_reader :base

    def initialize
      @base = "http://agora.md"
    end

    def build(id)
      "#{base}/stiri/#{id}/"
    end
  end

  class Publika
    attr_reader :base

    def initialize
      @base = "http://publika.md"
    end

    def build(id)
      "#{base}/#{id}/"
    end
  end

  class Timpul
    attr_reader :base

    def initialize
      @base = "http://www.timpul.md"
    end

    def build(id)
      "#{base}/u_#{id}/"
    end
  end

  class Unimedia
    attr_reader :base

    def initialize
      @base = "http://unimedia.info"
    end

    def build(id)
      "#{base}/stiri/-#{id}.html"
    end
  end
end
