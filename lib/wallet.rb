require_relative "mnemonic"
require_relative "bitcoin/patch"
require_relative "keys_generator"
require_relative "wallet/address"
require_relative "mempool/client"

class Wallet
  EXTERNAL_PULL = 7
  CHANGE_PULL = 5
  DEFAULT_FEE = 100 # satoshi

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
    external_addresses.map.with_index { |addr, i| "🟢 m/0/#{i}: #{addr.address} - #{addr.balance_mbtc}" }.concat(
      change_addresses.map.with_index { |addr, i| "🔴 m/1/#{i}: #{addr.address} - #{addr.balance_mbtc}" }
    ).join("\n")
  end

  def update_balances
    (addresses[:external] + addresses[:change])
      .map { |addr| Thread.new { addr.update_balance } }
      .each(&:join)
  end

  def external_addresses
    addresses[:external]
  end

  def change_addresses
    addresses[:change]
  end

  private

  def addresses
    @addresses ||= {
      external: leaves[:external].map { |leaf| Address.new(leaf.addr) },
      change: leaves[:change].map { |leaf| Address.new(leaf.addr) }
    }
  end

  # Takes too much time
  def generate_leaves
    account = root.derive_path("m/84H/1H/0H")
    external = account.derive(0)
    change = account.derive(1)

    {
      external: EXTERNAL_PULL.times.map { |i| external.derive(i) },
      change: CHANGE_PULL.times.map { |i| change.derive(i) }
    }
  end
end
