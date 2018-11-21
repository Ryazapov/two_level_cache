require "timecop"

RSpec.describe TwoLevelCache::Store do
  subject(:store) { described_class.new(cache_path: cache_path) }

  let(:cache_path) { "tmp/cache" }

  describe "#write" do
    subject(:write) { store.write("city", "Moscow") }

    it "writes Moscow to 'city' key" do
      expect { write }.to change { store.read("city") }.from(nil).to("Moscow")
    end

    context "when memory store is full" do
      let(:store) { described_class.new(size: 0.byte, cache_path: cache_path) }

      it "writes Moscow to 'city' key" do
        expect { write }.to change { store.read("city") }.from(nil).to("Moscow")
      end
    end
  end

  describe "#read" do
    subject(:read) { store.read("city") }

    it { is_expected.to be_nil }

    context "when store contains 'city' key" do
      before { store.write("city", "Moscow") }

      it { is_expected.to eq "Moscow" }

      context "and entry has been expired" do
        before do
          store.write("city", "Moscow", expires_in: 3)

          Timecop.travel(3.seconds.since)
        end

        it { is_expected.to be_nil }
      end

      context "and key exists in file store" do
        let(:store) { described_class.new(size: 0.byte, cache_path: cache_path) }

        before { store.write("city", "Moscow") }

        it { is_expected.to eq "Moscow" }
      end
    end
  end

  describe "#delete" do
    subject(:delete) { store.delete("city") }

    it { is_expected.to be_falsey }

    context "when store contains 'city' key" do
      before { store.write("city", "Moscow") }

      it "deletes 'city' key" do
        expect { delete }.to change { store.read("city") }.from("Moscow").to(nil)
      end
    end
  end

  describe "#prune" do
    subject(:prune) { store.prune(0.5.megabyte) }

    let(:store) { described_class.new(size: 1.megabyte, cache_path: cache_path) }

    before do
      store.write("moscow", "Moscow")
      store.write("kazan", "Kazan")
      store.write("london", "London")
      store.write("berlin", "Berlin")
    end

    it "moves values to file store" do
      prune

      expect(store.read("moscow")).to eq "Moscow"
      expect(store.read("kazan")).to eq "Kazan"
      expect(store.read("london")).to eq "London"
      expect(store.read("berlin")).to eq "Berlin"
    end
  end

  describe "#clear" do
    subject(:clear) { store.clear }

    before do
      store.write("moscow", "Moscow")
      store.write("kazan", "Kazan")
      store.write("london", "London")
      store.write("berlin", "Berlin")
    end

    it "clears memory store" do
      clear

      expect(store.read("moscow")).to be_nil
      expect(store.read("kazan")).to be_nil
      expect(store.read("london")).to be_nil
      expect(store.read("berlin")).to be_nil
    end

    context "when memory store is full" do
      let(:store) { described_class.new(size: 0.byte, cache_path: cache_path) }

      it "clears file store" do
        clear

        expect(store.read("moscow")).to be_nil
        expect(store.read("kazan")).to be_nil
        expect(store.read("london")).to be_nil
        expect(store.read("berlin")).to be_nil
      end
    end
  end

  describe "#cleanup" do
    subject(:cleanup) { store.cleanup }

    before do
      store.write("kazan", "Kazan")
      store.write("berlin", "Berlin", expires_in: 3)
      Timecop.travel(3.seconds.since)
    end

    it "cleanups memory store" do
      cleanup

      expect(store.read("kazan")).to eq "Kazan"
      expect(store.read("berlin")).to be_nil
    end

    context "when memory store is full" do
      let(:store) { described_class.new(size: 0.byte, cache_path: cache_path) }

      it "cleanups file store" do
        cleanup

        expect(store.read("kazan")).to eq "Kazan"
        expect(store.read("berlin")).to be_nil
      end
    end
  end

  describe "#increment" do
    subject(:increment) { store.increment("count") }

    it { is_expected.to be_nil }

    context "when store contains 'count' key" do
      before { store.write("count", 1) }

      it { is_expected.to eq 2 }

      context "and value is string" do
        before { store.write("count", "one") }

        it { is_expected.to eq 1 }
      end

      context "and memory store is full" do
        let(:store) { described_class.new(size: 0.byte, cache_path: cache_path) }

        it { is_expected.to eq 2 }
      end
    end
  end

  describe "#decrement" do
    subject(:decrement) { store.decrement("count") }

    it { is_expected.to be_nil }

    context "when store contains 'count' key" do
      before { store.write("count", 2) }

      it { is_expected.to eq 1 }

      context "and value is string" do
        before { store.write("count", "one") }

        it { is_expected.to eq(-1) }
      end

      context "and memory store is full" do
        let(:store) { described_class.new(size: 0.byte, cache_path: cache_path) }

        it { is_expected.to eq 1 }
      end
    end
  end
end
