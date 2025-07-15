require "openssl"

# It produces private master key for wallet from the mnemonic word list and optional pass phrase
class KeysGenerator
  class ArgumentError < StandardError; end

  HASHING_ROUNDS = 2048

  attr_reader :mnemonic, :passphrase, :seed, :master_key, :chain_code

  def self.run(mnemonic:, passphrase: "")
    new(mnemonic: mnemonic, passphrase: passphrase)
  end

  def initialize(mnemonic:, passphrase: "")
    @mnemonic = mnemonic
    @passphrase = passphrase
    validate_normalization
    generate_keys
  end

  private

  def generate_keys
    binary_seed = generate_binary_seed
    @seed = binary_seed.unpack1("H*")
    @master_key, @chain_code =
      OpenSSL::HMAC
        .digest(OpenSSL::Digest.new("SHA512"), "Bitcoin seed", binary_seed)
        .unpack1("H*")
        .then { |hex_string| [hex_string[0...64], hex_string[64..]] }
  end

  def generate_binary_seed
    OpenSSL::PKCS5.pbkdf2_hmac(mnemonic, "mnemonic#{passphrase}", HASHING_ROUNDS, 64, OpenSSL::Digest.new("SHA512"))
  end

  def validate_normalization
    [:mnemonic, :passphrase].each do |field|
      value = instance_variable_get("@#{field}")

      unless value == value.unicode_normalize(:nfkd)
        raise ArgumentError.new("Invalid input: #{field} must be in NFKD form")
      end
    end
  end
end
