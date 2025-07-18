require "bitcoin/patch"
require "keys_generator"
require "test_data"

describe "Bitcoin::ExtKey" do
  describe ".generate_master_by_private_key" do
    subject(:ext_key) { Bitcoin::ExtKey.generate_master_by_private_key(ext_priv) }

    let(:ext_priv) do
      "084667a541b4a5be45d3c4ead6763308213ae474acd0fca2fd8008b41047ad8c" \
        "ba1c517fcf6b97b1cfbcda48d11998928d4d183c12ab276ff4c60be1437732d1"
    end

    it "creates complete ExtKey object by known private key" do
      expect(ext_key).to be_an_instance_of(Bitcoin::ExtKey)
    end

    it "has contains proper fields", :aggregate_failures do
      expect(ext_key.depth).to eq 0
      expect(ext_key.number).to eq 0
      expect(ext_key.pub).to eq "026fb9e15aba93f4ec1d9aad7a70218494a66d91801d15e802d26da40c5a866902"
      expect(ext_key.priv).to eq "084667a541b4a5be45d3c4ead6763308213ae474acd0fca2fd8008b41047ad8c"
      expect(ext_key.key).to be_an_instance_of(Bitcoin::Key)
      expect(ext_key.chain_code.unpack1("H*")).to eq "ba1c517fcf6b97b1cfbcda48d11998928d4d183c12ab276ff4c60be1437732d1"
    end
  end

  describe "#derive_path" do
    let(:ext_key) do
      Bitcoin::ExtKey.generate_master(
        KeysGenerator.run(mnemonic: TestData.vector_one[:mnemonic]).seed
      )
    end

    it "generates the correct key" do
      expected_key = ext_key.derive(0, true).derive(1).derive(69)
      expect(ext_key.derive_path("m/0H/1/69")).to eq(expected_key)
    end

    context "when path is invalid" do
      it "raises error" do
        expect { ext_key.derive_path("m/zero") }.to raise_error(ArgumentError, /Can't handle 1 node .zero./)
      end
    end
  end

  describe "#parent" do
    let(:ext_key) do
      Bitcoin::ExtKey.generate_master(
        KeysGenerator.run(mnemonic: TestData.vector_one[:mnemonic]).seed
      )
    end

    context "when deriving old way" do
      it "assigns the correct ancestor to the descendant" do
        expect(ext_key.derive(0).parent).to eq(ext_key)
      end
    end

    context "when deriving path" do
      it "assigns the correct ancestor to the descendant" do
        expect(ext_key.derive_path("m/0/1").parent.parent).to eq(ext_key)
      end
    end
  end

  describe "walk through BIP84 test vectors" do
    subject(:ext_key) do
      Bitcoin::ExtKey.generate_master(KeysGenerator.run(mnemonic: TestData.bip84[:mnemonic]).seed)
    end

    it "generates right account 0'", :aggregate_failures do
      account0 = ext_key.derive_path("m/84H/0H/0H")
      expect(account0.to_base58).to eq(TestData.bip84[:account0][:xprv])
      expect(account0.ext_pubkey.to_base58).to eq(TestData.bip84[:account0][:xpub])
    end

    it "generates right zero receiving address 0'/0/0", :aggregate_failures do
      rcv_zero = ext_key.derive_path("m/84H/0H/0H/0/0")
      expect(rcv_zero.key.to_wif).to eq(TestData.bip84[:receive0][:prv_wif])
      expect(rcv_zero.pub).to eq(TestData.bip84[:receive0][:pub_wif])
      expect(rcv_zero.addr).to eq(TestData.bip84[:receive0][:addr])
    end

    it "generates right first receiving address 0'/0/1", :aggregate_failures do
      rcv_one = ext_key.derive_path("m/84H/0H/0H/0/1")
      expect(rcv_one.key.to_wif).to eq(TestData.bip84[:receive1][:prv_wif])
      expect(rcv_one.pub).to eq(TestData.bip84[:receive1][:pub_wif])
      expect(rcv_one.addr).to eq(TestData.bip84[:receive1][:addr])
    end

    it "generates right zero change address 0'/1/0", :aggregate_failures do
      chg_zero = ext_key.derive_path("m/84H/0H/0H/1/0")
      expect(chg_zero.key.to_wif).to eq(TestData.bip84[:change1][:prv_wif])
      expect(chg_zero.pub).to eq(TestData.bip84[:change1][:pub_wif])
      expect(chg_zero.addr).to eq(TestData.bip84[:change1][:addr])
    end
  end
end
