require_relative "mnemonic"
require_relative "bitcoin/patch"
require_relative "keys_generator"
require_relative "wallet/address"
require_relative "mempool/client"

class Wallet
  class TransactionError < StandardError; end

  EXTERNAL_PULL = 7
  CHANGE_PULL = 5
  DEFAULT_FEE = 250 # satoshi

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
    external_addresses.map.with_index { |addr, i| "🟢 m/0/#{i}: #{addr.balance_string}" }.concat(
      change_addresses.map.with_index { |addr, i| "🔴 m/1/#{i}: #{addr.balance_string}" }
    ).join("\n")
  end

  def update_balances
    all_addresses
      .map { |addr| Thread.new { addr.update_utxo } }
      .each(&:join)
  end

  def external_addresses
    addresses[:external]
  end

  def change_addresses
    addresses[:change]
  end

  # generates bitcoin transaction (SegWit)
  # @param [Array<String>] outputs - array of strings with address and optional amount in satoshi
  # @param [String] source_address
  def generate_transaction(outputs, source_address)
    # Сhecks and preparations
    index = all_addresses.find_index { |a| a.address == source_address }
    raise TransactionError, "Source address #{source_address} not found in the wallet" if index.nil?

    input_address, ext_key =
      if index < EXTERNAL_PULL
        [external_addresses[index], leaves[:external][index]]
      else
        [change_addresses[index - EXTERNAL_PULL], leaves[:change][index - EXTERNAL_PULL]]
      end

    outputs = outputs.map { |o| o.split }.map { |addr, val| [addr, val.to_i] }.sort_by { |_, val| -val }
    raise TransactionError, "More than one output with zero amount" if outputs.count { |_, val| val == 0 } > 1

    using_utxo = input_address.confirmed_utxo
    output_sum = outputs.sum { |_, val| val }
    balance = using_utxo.sum(&:value)

    raise TransactionError, "Insufficient balance on address #{input_address.address}" if balance <= output_sum

    outputs.last[1] = balance - output_sum - DEFAULT_FEE if outputs.last[1] == 0

    # Create transaction
    tx = Bitcoin::Tx.new
    input_pubkey = Bitcoin::Script.parse_from_addr(input_address.address)

    using_utxo.each do |utxo|
      tx.in << Bitcoin::TxIn.new(out_point: Bitcoin::OutPoint.from_txid(utxo.txid, utxo.vout))
    end

    outputs.each do |addr, val|
      output_pubkey = Bitcoin::Script.parse_from_addr(addr)
      tx.out << Bitcoin::TxOut.new(value: val, script_pubkey: output_pubkey)
    end

    using_utxo.each_with_index do |utxo, i|
      sig_hash = tx.sighash_for_input(i, input_pubkey, sig_version: :witness_v0, amount: utxo.value)
      signature = ext_key.key.sign(sig_hash) << "\x01"
      tx.in[i].script_witness.stack << signature
      tx.in[i].script_witness.stack << ext_key.pub.htb
    end

    # Verify transaction
    using_utxo.each_with_index do |utxo, i|
      unless tx.verify_input_sig(i, input_pubkey, amount: utxo.value)
        raise TransactionError, "Transaction verification failed"
      end
    end

    tx
  end

  private

  def addresses
    @addresses ||= {
      external: leaves[:external].map { |leaf| Address.new(leaf.addr) },
      change: leaves[:change].map { |leaf| Address.new(leaf.addr) }
    }
  end

  def all_addresses
    addresses[:external] + addresses[:change]
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
