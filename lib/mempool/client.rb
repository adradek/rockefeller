require "net/http"
require "uri"
require "json"

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

      def get_address_transactions(address)
        get_request("/address/#{address}/txs")
      end

      def get_address_utxo(address)
        get_request("/address/#{address}/utxo")
      end
    end
  end
end
