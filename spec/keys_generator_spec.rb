require "keys_generator"
require "test_vectors"

describe KeysGenerator do
  let(:passphrase) { "TREZOR" }

  TestVectors::VECTORS.each do |_, mnemonic, expected_seed|
    it "produces the right seed for specified mnemonic #{mnemonic}" do
      generator = described_class.run(mnemonic: mnemonic, passphrase: passphrase)
      expect(generator.seed).to eq(expected_seed)
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

  describe "master key and chain code generation" do
    subject(:generator) { described_class.run(mnemonic: mnemonic) }

    let(:mnemonic) { "skirt enact track fee kangaroo runway food force oppose very opinion lunar" }
    let(:seed) { "0eb8030b68169628faa328c880bd453ebb530b385dad2e09a5667756db615c01c67c033ef9c75a58dd9020674616e1422b9cca4b29db63ce8d348bb1c6772834" }

    it "generates right master key" do
      expect(generator.master_key).to eq("084667a541b4a5be45d3c4ead6763308213ae474acd0fca2fd8008b41047ad8c")
    end

    it "generates right chain code" do
      expect(generator.chain_code).to eq("ba1c517fcf6b97b1cfbcda48d11998928d4d183c12ab276ff4c60be1437732d1")
    end
  end
end
