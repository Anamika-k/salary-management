require "rails_helper"

RSpec.describe User, type: :model do
  describe "validations" do
    it "is valid with name, email and password" do
      expect(build(:user)).to be_valid
    end

    it "requires a name" do
      expect(build(:user, name: "")).not_to be_valid
    end

    it "requires a well-formed email" do
      expect(build(:user, email: "not-an-email")).not_to be_valid
    end

    it "rejects a duplicate email regardless of case" do
      create(:user, email: "hr@acme.test")
      expect(build(:user, email: "HR@acme.test")).not_to be_valid
    end

    it "requires a password of at least 6 characters" do
      expect(build(:user, password: "12345")).not_to be_valid
    end
  end

  describe "password storage" do
    it "never stores the plain password" do
      user = create(:user, password: "Secret123!")
      expect(user.encrypted_password).to be_present
      expect(user.encrypted_password).not_to include("Secret123!")
    end
  end

  describe "jti" do
    it "is generated on create" do
      expect(create(:user).jti).to be_present
    end

    it "is unique per user" do
      expect(create(:user).jti).not_to eq(create(:user).jti)
    end
  end

  describe "#active_for_authentication?" do
    it "is true for a live user" do
      expect(create(:user).active_for_authentication?).to be(true)
    end

    it "is false for a soft-deleted user" do
      expect(create(:user, :deleted).active_for_authentication?).to be(false)
    end
  end
end
