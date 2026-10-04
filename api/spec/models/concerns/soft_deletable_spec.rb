require "rails_helper"

# Exercised through User; every soft-deletable model shares this behaviour.
RSpec.describe SoftDeletable do
  let!(:live) { create(:user) }
  let!(:deleted) { create(:user, :deleted) }

  describe ".kept" do
    it "returns only live records" do
      expect(User.kept).to contain_exactly(live)
    end
  end

  describe ".deleted" do
    it "returns only soft-deleted records" do
      expect(User.deleted).to contain_exactly(deleted)
    end
  end

  describe "#soft_delete!" do
    it "marks the record deleted without removing the row" do
      freeze_time do
        live.soft_delete!
        expect(live.reload.deleted_at).to eq(Time.current)
      end
      expect(User.exists?(live.id)).to be(true)
    end
  end

  describe "#restore!" do
    it "brings a deleted record back" do
      deleted.restore!
      expect(deleted.reload).not_to be_deleted
      expect(User.kept).to include(deleted)
    end
  end

  describe "#deleted?" do
    it "reflects deleted_at" do
      expect(live).not_to be_deleted
      expect(deleted).to be_deleted
    end
  end
end
