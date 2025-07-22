class TestData
  VECTOR_ONE = {
    mnemonic: "skirt enact track fee kangaroo runway food force oppose very opinion lunar",
    seed: "0eb8030b68169628faa328c880bd453ebb530b385dad2e09a5667756db615c01c67c033ef9c75a58dd9020674616e1422b9cca4b29db63ce8d348bb1c6772834",
    private_key: "084667a541b4a5be45d3c4ead6763308213ae474acd0fca2fd8008b41047ad8c",
    chain_code: "ba1c517fcf6b97b1cfbcda48d11998928d4d183c12ab276ff4c60be1437732d1",
    addresses: [
      "tb1qcumhr4pu8wukza39g5ef7t4spxk2cfe0xer7qp",
      "tb1q2yakzsctsrlse28e5hau06uz8nrkvu0feslunj",
      "tb1qkzl84qaz2wkecffzn2awhzx3a9et89epzh72ly",
      "tb1q9nuu0gvyeh0sl7cp83gu803dt4wte4senmrdyl",
      "tb1qnkw29x0tm4fqxetpt7z7vv5lfkr6728u6p7uap",
      "tb1qfmg6r24ar7j3st34v2gxm56leah9r3m7nuqx7d",
      "tb1qjt2hv56jn30t6javtfzk6eqe4as72k3nkes24y",
      "tb1ql092edyjg3wp0xlpepkxzcwk9en22rrcjske7f",
      "tb1qqz9306q9hhqu4vp56t0vz6azlj0prfx7acgt40",
      "tb1qcc4u5zk42397rcetlm7af07gxyvlm7yt82qakj",
      "tb1qzlhzmzte6u99lnfqvwyw2j389pp4rqyanfret8",
      "tb1qqhptr6v7pu5c9ukv9ru0w3sxjuj28vnu6ezkq0"
    ]
  }

  VECTOR_TWO = {
    mnemonic: "chief alter harvest top doll body recycle weather expand cry squirrel sausage",
    seed: "f631f272c6930af44c0716e95f781c83c1e6a4bc7a0b4ab37383c4f0a8e84a495225c536cc6c539defecf3066cf407a5dc2682ceb715dd79ba5638a71f7494e8",
    private_key: "78b50f39078d53964b54d2f6834e3eec54166ffd263efbd54962924cd443efe7",
    chain_code: "d523ea124a513b35cc652e1523ca72457605e9bb1124c179ce72ca4f0f0b277b",
    addresses: [
      "tb1q6pk660sn78tjq7rsdp7dwj8l02rnytz90e9kx8",
      "tb1qnkrkwy0wn9tltwmnqlj7j73f2wnle6m50hh53d",
      "tb1ql4vtsxmhvz6ny3j2gkm2ruxv2lnf5j6cckyy4z",
      "tb1qa35uzdzzx3l6aef7nn6rr243flaq237vwgpxuz",
      "tb1q2auskj99u5c79gy0hn2yluzrc4k9qnlecqh2t7",
      "tb1q52gt6lu8hxnhxlhw4fj52ak7s64hscn06zrwv6",
      "tb1q7xpc9ew2r3ceacj523d3c5m3hj9ugl3k8y0y0w",
      "tb1q2hw5mufy3qc7kwejfhkdvtkptgjn2tahk6t7x5",
      "tb1qq2duge948mxlwdf844wlahsdemt745ez2fvm6g",
      "tb1qq606uwj9cxdwu7adhvhy8pffqgfrt7lkjc9dw8",
      "tb1qes2d3h2krftqagfqptua734ml90da66deduss8",
      "tb1qhh8h7ajap5nsa2k9szez3nz7ja02y9px20gz3w"
    ]
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

  def self.vector_two
    VECTOR_TWO
  end

  def self.bip84
    BIP84
  end
end
