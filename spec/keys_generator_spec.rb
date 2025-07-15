require "keys_generator"
require_relative "misc/test_vectors"

describe KeysGenerator do
  let(:passphrase) { "TREZOR" }

  TestVectors::VECTORS.each do |_, mnemonic, expected_seed|
    it "produces right private key for specified mnemonic #{mnemonic}" do
      generator = described_class.run(mnemonic: mnemonic, passphrase: passphrase)
      expect(generator.seed512).to eq(expected_seed)
    end
  end

  describe "mnemonic NFKD validation" do
    let(:generator) { described_class.new(mnemonic: mnemonic) }

    context "when mnemonic has NFKD" do
      let(:mnemonic) { 12.times.map { "Amélie" }.join(" ") }

      it "doesn't raise error" do
        expect { generator }.not_to raise_error
      end
    end

    context "when mnemonic has no NFKD" do
      let(:mnemonic) { 12.times.map { "\u0041\u006d\u00e9\u006c\u0069\u0065" }.join(" ") }

      it "raises error" do
        expect { generator }.to raise_error(KeysGenerator::ArgumentError, /mnemonic must be in NFKD form/)
      end
    end
  end

  describe "passphrase NFKD validation" do
    let(:generator) { described_class.new(mnemonic: "good old mnemonic phrase", passphrase: passphrase) }

    context "when passphrase has NFKD" do
      let(:passphrase) { "Amélie" }

      it "doesn't raise error" do
        expect { generator }.not_to raise_error
      end
    end

    context "when passphrase has no NFKD" do
      let(:passphrase) { "\u0041\u006d\u00e9\u006c\u0069\u0065" }

      it "raises error" do
        expect { generator }.to raise_error(KeysGenerator::ArgumentError, /passphrase must be in NFKD form/)
      end
    end
  end
end
