require "mnemonic"
require "test_vectors"

describe Mnemonic do
  describe "#wordlist" do
    TestVectors::VECTORS.each do |entropy, expected_mnemonic|
      it "produces right mnemonic for specified entropy #{entropy}" do
        mnemonic = described_class.new(entropy)
        expect(mnemonic.wordlist).to eq(expected_mnemonic.split(" "))
      end
    end
  end

  describe ".generate_random" do
    context "with illegal strength of entropy" do
      it "raises error", :aggregate_failures do
        [121, 144, 200, 512].each do |entropy_bits|
          expect { described_class.generate_random(entropy_bits) }
            .to raise_error(ArgumentError, /.#{entropy_bits} bits. is not in the list of acceptable values/)
        end
      end
    end

    context "with valid strength" do
      subject(:described_method) { described_class.method(:generate_random) }

      let(:strengths) { described_class::VALID_ENTROPY_STRENGTHS }

      it "produces Mnemonic object", :aggregate_failures do
        strengths.each do |strength|
          expect(described_method.call(strength)).to be_an_instance_of(described_class)
        end
      end

      it "generates right entropy", :aggregate_failures do
        strengths.each do |strength|
          mnemonic = described_method.call(strength)
          expect(mnemonic.entropy.size).to eq(strength / 4) # 1 hex = 4 bits
        end
      end

      it "generates the word list of the corresponding length" do
        strengths.each do |strength|
          mnemonic = described_method.call(strength)
          expect(mnemonic.wordlist.size).to eq(strength / 32 * 3)
        end
      end
    end
  end
end
