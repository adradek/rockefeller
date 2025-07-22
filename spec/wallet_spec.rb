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

  describe "#generate_transaction" do
    let(:wallet) do
      described_class.restore_from_seed(name: "test", seed: TestData.vector_two[:seed]).tap do |wallet|
        allow(wallet).to receive(:all_addresses).and_return(TestData.vector_two[:addresses]
          .map { |addr| Wallet::Address.new(addr) })
      end
    end

    let(:outputs) { ["tb1qcumhr4pu8wukza39g5ef7t4spxk2cfe0xer7qp 2476", "tb1q2yakzsctsrlse28e5hau06uz8nrkvu0feslunj 1000"] }
    let(:source_address) { "tb1qq2duge948mxlwdf844wlahsdemt745ez2fvm6g" }

    context "when source_address doesn't belong to the wallet" do
      it "raises error" do
        source_address = "tb1qTotaLyWierdAddress00000000000000000000"
        expect { wallet.generate_transaction(outputs, source_address) }
          .to raise_error(Wallet::TransactionError, "Source address #{source_address} not found in the wallet")
      end
    end

    context "when more than one output with not specified amount" do
      it "raises error" do
        outputs = ["tb1qcumhr4pu8wukza39g5ef7t4spxk2cfe0xer7qp", "tb1q2yakzsctsrlse28e5hau06uz8nrkvu0feslunj"]
        expect { wallet.generate_transaction(outputs, source_address) }
          .to raise_error(Wallet::TransactionError, "More than one output with zero amount")
      end
    end
  end
end
