require_relative "mnemonic"
require_relative "bitcoin/patch"
require_relative "keys_generator"
require_relative "wallet/address_data"
require_relative "mempool/client"

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
    external_addresses.map.with_index { |addr, i| "🟢 m/0/#{i}: #{addr} - #{balance(addr)}" }.concat(
      change_addresses.map.with_index { |addr, i| "🔴 m/1/#{i}: #{addr} - #{balance(addr)}" }
    ).join("\n")
  end

  def balances
    @balances ||= get_balances_concurrent
  end

  # 2 seconds 10 requests
  def get_balances
    all_addresses.map do |address|
      data = Mempool::Client.get_address_stats(address)
      [address, AddressData.new(data).balance_cents]
    end.to_h
  end

  # 0.3 seconds 10 requests
  def get_balances_concurrent
    results = {}
    mutex = Mutex.new

    all_addresses.map do |address|
      Thread.new do
        data = Mempool::Client.get_address_stats(address)
        balance = AddressData.new(data).balance_cents
        mutex.synchronize { results[address] = balance }
      end
    end.each(&:join)

    results
  end

  private

  def all_addresses
    external_addresses.concat(change_addresses)
  end

  def external_addresses
    leaves[:external].map(&:addr)
  end

  def change_addresses
    leaves[:change].map(&:addr)
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

  def balance(address)
    balances[address].to_f / 10_000
  end
end
