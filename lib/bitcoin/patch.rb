require "bitcoin"

module Bitcoin
  # It adds a class method to the existing class of the 'bitcoinrb' gem
  class ExtKey
    # produce an instance by master private key
    # @params [String] private_key
    def self.generate_master_by_private_key(private_key)
      ext_key = ExtKey.new
      ext_key.depth = ext_key.number = 0
      ext_key.parent_fingerprint = MASTER_FINGERPRINT
      left = private_key[0..63].to_i(16)
      raise "invalid key" if left >= CURVE_ORDER || left == 0
      l_priv = ECDSA::Format::IntegerOctetString.encode(left, 32)
      ext_key.key = Bitcoin::Key.new(priv_key: l_priv.bth, key_type: Bitcoin::Key::TYPES[:compressed])
      ext_key.chain_code = private_key.htb[32..]
      ext_key
    end
  end
end
