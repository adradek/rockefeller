class Wallet
  class AddressData
    def initialize(data)
      @data = data
    end

    def balance
      balance_cents / 10_000
    end

    def balance_cents
      data["chain_stats"].then { |cs| cs["funded_txo_sum"] - cs["spent_txo_count"] }
    end

    private

    attr_reader :data
  end
end
