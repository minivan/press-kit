module Config
  module Database
    class << self
      def setup
        if ENV['ENV'] == "production"
          Mongoid.load!("mongoid.yml", :production)
        else
          Mongoid.load!("mongoid.yml", :development)
        end
      end
    end
  end
end
