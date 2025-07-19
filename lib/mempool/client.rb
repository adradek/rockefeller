require "net/http"
require "uri"

module Mempool
  class Client
    BASE_URL = "https://mempool.space/signet/api"

    class << self
      def get_request(path)
        url = URI("#{BASE_URL}#{path}")
        response = Net::HTTP.get(url)
        JSON.parse(response)
      end

      def get_address_stats(address)
        get_request("/address/#{address}")
      end
    end
  end
end
