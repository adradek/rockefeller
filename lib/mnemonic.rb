require "digest"

# This class is responsible for the seed phrase generation according to BIP-39 (English only)
class Mnemonic
  class ArgumentError < StandardError; end

  VALID_ENTROPY_SIZES = [128, 160, 192, 224, 256]

  attr_reader :entropy

  def initialize(entropy)
    @entropy = entropy
    validate_entropy
  end

  def wordlist
    @wordlist ||= generate_wordlist
  end

  def strength
    entropy.size * 4
  end

  private

  def generate_wordlist
    appended_entropy_bitstring
      .chars
      .each_slice(11)
      .map { |arr| dictionary[arr.join.to_i(2)] }
  end

  def validate_entropy
    raise ArgumentError.new("Input entropy must be a string form of a hex number") unless entropy =~ /\A[0-9a-h]+\z/

    unless VALID_ENTROPY_SIZES.include?(strength)
      raise ArgumentError.new("Input entropy is of invalid length (#{strength} bits)")
    end
  end

  def appended_entropy_bitstring
    binary_entropy = [entropy].pack("H*")
    cs = ::Digest::SHA256.digest(binary_entropy).unpack1("B*")
    needed_bits = strength / 32
    binary_entropy.unpack1("B*") << cs[0...needed_bits]
  end

  def dictionary
    @dictionary ||= load_dictionary
  end

  def load_dictionary
    gem_spec = Gem::Specification.find_by_name("bitcoinrb")
    english_wordlist_path = File.join(gem_spec.gem_dir, "lib", "bitcoin", "mnemonic", "wordlist", "english.txt")
    File.readlines(english_wordlist_path).map(&:strip)
  rescue e
    warn "❌ An error occured while trying to read the mnemonic wordlist file #{english_wordlist_path}"
    raise e
  end
end
