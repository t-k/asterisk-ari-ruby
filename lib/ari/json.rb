require "multi_json"

module ARI
  module JSON

    def self.dump(*args)
      if MultiJson.respond_to?(:dump)
        MultiJson.dump(*args)
      else
        MultiJson.encode(*args)
      end
    end

    def self.load(*args)
      if MultiJson.respond_to?(:load)
        MultiJson.load(*args)
      else
        MultiJson.decode(*args)
      end
    end

  end
end