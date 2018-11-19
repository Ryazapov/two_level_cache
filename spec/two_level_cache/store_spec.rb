require "timecop"

RSpec.describe TwoLevelCache::Store do
  subject(:store) { described_class.new(cache_path: "spec/tmp") }

  describe "#read" do
    subject(:read) { store.read("city") }

    it { is_expected.to be_nil }

    context "when store contain city key" do
      before { store.write("city", "Moscow"); }

      it { is_expected.to eq "Moscow" }

      context "and entry has been expired" do
        before { store.write("city", "Moscow", expires_in: 3) }

        it "returns nil" do
          Timecop.freeze(3.seconds.since) do
            is_expected.to eq nil
          end
        end
      end
    end
  end
end
