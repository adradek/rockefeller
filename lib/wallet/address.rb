require_relative "../mempool/client"
require_relative "utxo"

class Wallet
  class Address
    attr_reader :address

    def initialize(address)
      @address = address
    end

    def balance_mbtc
      balance.to_f / 100_000
    end

    def balance
      utxo.sum(&:value)
    end

    def utxo
      @utxo ||= update_utxo
    end

    def confirmed_utxo
      utxo.select { |item| item.data["status"]["confirmed"] }
    end

    # def update_balance
    #   data = Mempool::Client.get_address_stats(address)
    #   @balance = data["chain_stats"].then { |cs| cs["funded_txo_sum"] - cs["spent_txo_sum"] }
    # end

    def update_utxo
      payload = Mempool::Client.get_address_utxo(address)
      @utxo = payload.map { |data| UTXO.new(data) }
    end
  end
end
