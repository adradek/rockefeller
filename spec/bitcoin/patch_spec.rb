require "bitcoin/patch"

describe "Bitcoin::ExtKey" do
  describe ".generate_master_by_private_key" do
    subject(:ext_key) { Bitcoin::ExtKey.generate_master_by_private_key(ext_priv) }

    let(:ext_priv) do
      "084667a541b4a5be45d3c4ead6763308213ae474acd0fca2fd8008b41047ad8cba1c517fcf6b97b1cfbcda48d11998928d4d183c12ab276ff4c60be1437732d1"
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
end
