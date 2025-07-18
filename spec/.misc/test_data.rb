class TestData
  VECTOR_ONE = {
    mnemonic: "skirt enact track fee kangaroo runway food force oppose very opinion lunar",
    seed: "0eb8030b68169628faa328c880bd453ebb530b385dad2e09a5667756db615c01c67c033ef9c75a58dd9020674616e1422b9cca4b29db63ce8d348bb1c6772834",
    private_key: "084667a541b4a5be45d3c4ead6763308213ae474acd0fca2fd8008b41047ad8c",
    chain_code: "ba1c517fcf6b97b1cfbcda48d11998928d4d183c12ab276ff4c60be1437732d1"
  }

  BIP84 = {
    mnemonic: "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about",

    account0: {
      xprv: "zprvAdG4iTXWBoARxkkzNpNh8r6Qag3irQB8PzEMkAFeTRXxHpbF9z4QgEvBRmfvqWvGp42t42nvgGpNgYSJA9iefm1yYNZKEm7z6qUWCroSQnE",
      xpub: "zpub6rFR7y4Q2AijBEqTUquhVz398htDFrtymD9xYYfG1m4wAcvPhXNfE3EfH1r1ADqtfSdVCToUG868RvUUkgDKf31mGDtKsAYz2oz2AGutZYs"
    },

    receive0: {
      prv_wif: "KyZpNDKnfs94vbrwhJneDi77V6jF64PWPF8x5cdJb8ifgg2DUc9d",
      pub_wif: "0330d54fd0dd420a6e5f8d3624f5f3482cae350f79d5f0753bf5beef9c2d91af3c",
      addr: "bc1qcr8te4kr609gcawutmrza0j4xv80jy8z306fyu"
    },

    receive1: {
      prv_wif: "Kxpf5b8p3qX56DKEe5NqWbNUP9MnqoRFzZwHRtsFqhzuvUJsYZCy",
      pub_wif: "03e775fd51f0dfb8cd865d9ff1cca2a158cf651fe997fdc9fee9c1d3b5e995ea77",
      addr: "bc1qnjg0jd8228aq7egyzacy8cys3knf9xvrerkf9g"
    },

    change1: {
      prv_wif: "KxuoxufJL5csa1Wieb2kp29VNdn92Us8CoaUG3aGtPtcF3AzeXvF",
      pub_wif: "03025324888e429ab8e3dbaf1f7802648b9cd01e9b418485c5fa4c1b9b5700e1a6",
      addr: "bc1q8c6fshw2dlwun7ekn9qwf37cu2rn755upcp6el"
    }
  }

  def self.vector_one
    VECTOR_ONE
  end

  def self.bip84
    BIP84
  end
end
