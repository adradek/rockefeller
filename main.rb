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

if (wallets = Storage::Operations.wallets).empty?
  Interactive.no_wallets
else
  Interactive.show_wallets(wallets)
end

action = gets.strip

exit(0) if QUIT_COMMANDS.include?(action)

_wallet =
  if action.empty? && wallets.empty?
    generate_wallet(DEFAULT_WALLET)
  elsif action.empty? && wallets.include?(DEFAULT_WALLET)
    restore_wallet(DEFAULT_WALLET)
  elsif action.empty?
    restore_wallet(Storage::Operations.latest_wallet)
  elsif wallets.include?(action)
    restore_wallet(action)
  else
    generate_wallet(action)
  end

puts "\n\n\n"
