require "wallet"
require "test_data"

describe Wallet do
  describe ".generate_by_mnemonic" do
    subject(:method_call) do
      described_class.generate_by_mnemonic(name: name, mnemonic: TestData.vector_one[:mnemonic], passphrase: "")
    end

    let(:name) { "default" }

    it "generates instance of wallet" do
      expect(method_call).to be_an_instance_of(described_class)
    end

    it "stores the name" do
      expect(method_call.name).to eq(name)
    end

    it "stores the mnemonic" do
      expect(method_call.precursors.mnemonic).to eq(TestData.vector_one[:mnemonic])
    end

    it "stores the passphrase" do
      expect(method_call.precursors.passphrase).to eq("")
    end

    it "generates proper seed" do
      expect(method_call.precursors.seed).to eq(TestData.vector_one[:seed])
    end

    it "generates proper private key" do
      expect(method_call.root.priv).to eq(TestData.vector_one[:private_key])
    end
  end

  describe ".restore_from_seed" do
    subject(:method_call) do
      described_class.restore_from_seed(name: name, seed: TestData.vector_one[:seed])
    end

    let(:name) { "reserve" }

    it "generates instance of wallet" do
      expect(method_call).to be_an_instance_of(described_class)
    end

    it "stores the name" do
      expect(method_call.name).to eq(name)
    end

    it "doesn't store the precursors" do
      expect(method_call.precursors).to be_nil
    end

    it "generates proper private key" do
      expect(method_call.root.priv).to eq(TestData.vector_one[:private_key])
    end

    it "generates proper chain code" do
      expect(method_call.root.chain_code.bth).to eq(TestData.vector_one[:chain_code])
    end
  end
end
