require "rails_helper"

RSpec.describe "db/seeds.rb" do
  def run_seeds
    silence_stream($stdout) { load Rails.root.join("db/seeds.rb") }
  end

  def silence_stream(stream)
    original = stream.dup
    stream.reopen(File::NULL)
    yield
  ensure
    stream.reopen(original)
  end

  it "creates an HR Manager who can sign in" do
    run_seeds
    user = User.find_by(email: "hr@acme.com")

    expect(user).to be_present
    expect(user.valid_password?("ChangeMe123!")).to be(true)
  end

  it "is idempotent: running twice creates nothing new" do
    run_seeds
    expect { run_seeds }.not_to change(User, :count)
  end

  it "never overwrites an existing user's password" do
    create(:user, email: "hr@acme.com", password: "MyOwnPass1!")
    run_seeds

    expect(User.find_by(email: "hr@acme.com").valid_password?("MyOwnPass1!")).to be(true)
  end
end
