require "rails_helper"

RSpec.describe Departments::CreateService do
  it "creates a new department" do
    department = described_class.new(name: "Legal").call
    expect(department).to be_persisted
    expect(department.name).to eq("Legal")
  end

  it "restores a soft-deleted department with the same name instead of failing" do
    old = create(:department, :deleted, name: "Legal")
    expect(described_class.new(name: " legal ").call).to eq(old)
    expect(old.reload).not_to be_deleted
  end

  it "rejects the name of a live department" do
    create(:department, name: "Legal")
    expect { described_class.new(name: "LEGAL").call }.to raise_error(ActiveRecord::RecordInvalid)
  end

  it "rejects a blank name" do
    expect { described_class.new(name: "").call }.to raise_error(ActiveRecord::RecordInvalid)
  end
end
