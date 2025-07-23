$LOAD_PATH.unshift File.expand_path("lib", __dir__)

require "bitcoin"
require "bitcoin/patch"
require "storage/operations"
require "interactive"
require "wallet"
require "encryptor"

Bitcoin.chain_params = :signet

DEFAULT_WALLET = "default"
QUIT_COMMANDS = %w[q quit x exit]

def generate_wallet(name)
  Interactive.show_new_wallet(name)
  user_password = gets.strip
  Interactive.ask_for_mnemonic
  user_mnemonic = gets.strip

  Wallet.generate_by_mnemonic(name: name, mnemonic: user_mnemonic, passphrase: user_password).tap do |wallet|
    Interactive.show_generated_mnemonic(wallet.precursors.mnemonic) if user_mnemonic.empty?
    binary_seed = wallet.precursors.seed.htb
    cypher_text = Encryptor.new(user_password).encrypt(binary_seed)
    Storage::Operations.save_seed(name, cypher_text)
    Interactive.wallet_created(wallet)
  end
end

def restore_wallet(name)
  Interactive.show_restore_wallet(name)
  user_password = gets.strip

  cypher_text = Storage::Operations.load_seed(name)
  seed = Encryptor.new(user_password).decrypt(cypher_text).bth

  Wallet.restore_from_seed(name: name, seed: seed).tap do |wallet|
    Interactive.wallet_restored(wallet)
  end
rescue OpenSSL::Cipher::CipherError
  Interactive.unable_to_restore_wallet
  exit(1)
end

def interruptible_gets
  gets.strip.tap { |input| exit(0) if QUIT_COMMANDS.include?(input) }
end

if (wallets = Storage::Operations.wallets).empty?
  Interactive.no_wallets
else
  Interactive.show_wallets(wallets)
end

wallet_name = gets.strip

wallet =
  if wallet_name.empty? && wallets.empty?
    generate_wallet(DEFAULT_WALLET)
  elsif wallet_name.empty? && wallets.include?(DEFAULT_WALLET)
    restore_wallet(DEFAULT_WALLET)
  elsif wallet_name.empty?
    restore_wallet(Storage::Operations.latest_wallet)
  elsif wallets.include?(wallet_name)
    restore_wallet(wallet_name)
  else
    generate_wallet(wallet_name)
  end

# Each iteration generates and sends transaction
loop do
  outputs = []

  loop do
    output = interruptible_gets
    break if output.empty?
    outputs << output
    break if output.split.size == 1 # change address (without amount)
    Interactive.standard_prompt
  end

  unless outputs.empty?
    Interactive.ask_for_source_address
    source_address = interruptible_gets
    tx = wallet.generate_transaction(outputs, source_address)
    payload = Mempool::Client.broadcast_transaction(tx.to_hex)

    Interactive.transaction_report(payload)
    interruptible_gets
  end

  Interactive.show_wallet(wallet)
end

puts "\n\n\n"
