class Wallet
  class UTXO
    attr_reader :data

    def initialize(data)
      @data = data
    end

    def txid
      data["txid"]
    end

    def vout
      data["vout"]
    end

    def value
      data["value"]
    end
  end
end
