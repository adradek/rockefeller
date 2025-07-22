require "net/http"
require "uri"
require "json"

module Mempool
  class Client
    class Error < StandardError; end

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

      def broadcast_transaction(raw_tx)
        url = URI("#{BASE_URL}/tx")
        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = (url.scheme == "https")

        request = Net::HTTP::Post.new(url.request_uri)
        request.body = raw_tx
        request["Content-Type"] = "text/plain"

        response = http.request(request)
        if response.code != "200"
          raise Error, "Mempool error: #{response.body}"
        end

        response.body
      end
    end
  end
end
