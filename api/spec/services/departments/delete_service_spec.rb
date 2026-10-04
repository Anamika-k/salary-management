require "rails_helper"

RSpec.describe Departments::DeleteService do
  let(:department) { create(:department) }

  it "soft deletes an empty department" do
    described_class.new(department).call
    expect(department.reload).to be_deleted
  end

  it "allows deleting when only soft-deleted employees remain" do
    create(:employee, :deleted, department:)
    described_class.new(department).call
    expect(department.reload).to be_deleted
  end

  it "refuses while live employees belong to it, terminated ones included" do
    create(:employee, :terminated, department:)
    expect { described_class.new(department).call }.to raise_error(Departments::InUseError, /1 employee/)
    expect(department.reload).not_to be_deleted
  end
end
