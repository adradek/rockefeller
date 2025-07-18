module Storage
  KEYS_FOLDER = File.expand_path("../../.keys", __dir__)
  SEED_FILES = File.join(KEYS_FOLDER, "*.seed")

  class Operations
    def self.seed_files
      Dir.glob(SEED_FILES)
    end

    def self.wallets
      seed_files.map { |fname| File.basename(fname)[...-5] }
    end

    def self.latest_wallet
      latest = seed_files.max_by { |fname| Pathname.new(fname).birthtime }
      latest && latest.split("/").last[...-5]
    end

    def self.save_seed(name, cypher_text)
      File.write(File.join(KEYS_FOLDER, "#{name}.seed"), cypher_text)
    end

    def self.load_seed(name)
      File.read(File.join(KEYS_FOLDER, "#{name}.seed"))
    end
  end
end
