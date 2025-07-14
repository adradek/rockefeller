require 'mnemonic'
require_relative "misc/test_vectors.rb"

describe Mnemonic do
  TestVectors::VECTORS.each do |entropy, expected_mnemonic|
    it "produces right mnemonic for specified entropy #{entropy}" do
      mnemonic = described_class.new(entropy)
      expect(mnemonic.wordlist).to eq(expected_mnemonic.split(" "))
    end
  end
end
