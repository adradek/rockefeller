module Storage
  SEED_FILES = File.expand_path("../../.keys/*.seed", __dir__)

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
  end
end
