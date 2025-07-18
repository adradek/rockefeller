require "mnemonic"
require "bitcoin/patch"
require "keys_generator"

class Wallet
  EXTERNAL_PULL = 5
  CHANGE_PULL = 5

  def self.generate_by_mnemonic(name:, mnemonic:, passphrase: "")
    mnemonic =
      if mnemonic && mnemonic.size > 0
        mnemonic.split.join(" ")
      else
        Mnemonic.generate_random(128).wordlist.join(" ")
      end

    keys = KeysGenerator.run(mnemonic: mnemonic, passphrase: passphrase)

    root = Bitcoin::ExtKey.generate_master_by_private_key(keys.ext_private_key)
    new(name: name, root: root, precursors: keys)
  end

  def self.restore_from_seed(name:, seed:)
    root = Bitcoin::ExtKey.generate_master(seed)
    new(name: name, root: root)
  end

  attr_reader :name, :root, :precursors

  def initialize(name:, root:, precursors: nil)
    @name = name
    @root = root
    @precursors = precursors
  end

  def leaves
    @leaves ||= generate_leaves
  end

  def to_s
    external_addresses.map.with_index { |addr, i| "🟢 m/0/#{i}: #{addr}" }.concat(
      change_addresses.map.with_index { |addr, i| "🔴 m/1/#{i}: #{addr}" }
    ).join("\n")
  end

  private

  def external_addresses
    leaves[:external].map(&:addr)
  end

  def change_addresses
    leaves[:change].map(&:addr)
  end

  def generate_leaves
    account = root.derive_path("m/84H/1H/0H")

    puts "root fingerprint: #{root.fingerprint}"
    puts "account fingerprint: #{account.fingerprint}"
    external = account.derive(0)
    change = account.derive(1)

    {
      external: EXTERNAL_PULL.times.map { |i| external.derive(i) },
      change: CHANGE_PULL.times.map { |i| change.derive(i) }
    }
  end
end
