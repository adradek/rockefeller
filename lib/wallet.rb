require "mnemonic"
require "bitcoin/patch"
require "keys_generator"

class Wallet
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
end
