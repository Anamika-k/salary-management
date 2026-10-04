require "rails_helper"

RSpec.describe AuditLog do
  it "is valid with the factory defaults" do
    expect(build(:audit_log)).to be_valid
  end

  it "requires a user, an action and a change set" do
    log = build(:audit_log, user: nil, action: nil, change_set: nil)
    expect(log).not_to be_valid
    expect(log.errors.attribute_names).to include(:user, :action, :change_set)
  end

  it "rejects an unknown action" do
    expect(build(:audit_log, action: "viewed")).not_to be_valid
  end

  it "can't be changed once written" do
    log = create(:audit_log)
    expect(log).to be_readonly
  end
end
