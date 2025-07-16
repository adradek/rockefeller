require "bitcoin"

module Bitcoin
  module MemoryOfAncestors
    def derive(number, harden = false)
      super.tap { |child| child.parent = self }
    end
  end

  # It adds a class method to the existing class of the 'bitcoinrb' gem
  class ExtKey
    prepend MemoryOfAncestors

    attr_accessor :parent

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

    # TODO: Replace this method at the end
    def self.shortcut
      generate_master_by_private_key("084667a541b4a5be45d3c4ead6763308213ae474acd0fca2fd8008b41047ad8cba1c517fcf6b97b1cfbcda48d11998928d4d183c12ab276ff4c60be1437732d1")
    end

    # Generates a deep nesting key
    # @param [String] path - path to new private key, starting with "m"
    def derive_path(path)
      parent = self
      child = nil

      path.split("/").compact.each_with_index do |node, i|
        child =
          case node
          when "m" then self
          when /\A\d+\z/ then parent.derive(node.to_i)
          when /\A\d+H\z/ then parent.derive(node.to_i, true)
          else
            raise ArgumentError.new("Can't handle #{i} node (#{node}) in the path #{path.inspect}")
          end

        parent = child
      end

      child
    end
  end
end
