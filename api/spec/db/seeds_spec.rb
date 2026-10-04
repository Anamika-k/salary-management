require "rails_helper"

RSpec.describe "db/seeds.rb" do
  around do |example|
    ENV["SEED_EMPLOYEE_COUNT"] = "200"
    example.run
  ensure
    ENV.delete("SEED_EMPLOYEE_COUNT")
  end

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

  it "never overwrites an existing user's password" do
    create(:user, email: "hr@acme.com", password: "MyOwnPass1!")
    run_seeds

    expect(User.find_by(email: "hr@acme.com").valid_password?("MyOwnPass1!")).to be(true)
  end

  it "creates the standard departments" do
    run_seeds
    expect(Department.kept.pluck(:name)).to include("Engineering", "Finance", "Human Resources")
  end

  describe "employees" do
    before { run_seeds }

    it "creates the requested number with sequential codes" do
      expect(Employee.count).to eq(200)
      expect(Employee.order(:employee_code).pluck(:employee_code).values_at(0, -1)).to eq(%w[EMP000001 EMP000200])
    end

    it "creates only records that pass every model validation" do
      expect(Employee.includes(:department).reject(&:valid?)).to be_empty
    end

    it "spreads employees across countries, departments and statuses" do
      expect(Employee.distinct.count(:country_code)).to be > 3
      expect(Employee.distinct.count(:department_id)).to be > 5
      expect(Employee.distinct.pluck(:employment_status)).to match_array(%w[active on_leave terminated])
    end

    it "produces the same data on every run" do
      first = Employee.order(:employee_code).pluck(:employee_code, :email, :country_code)
      Employee.delete_all
      run_seeds
      expect(Employee.order(:employee_code).pluck(:employee_code, :email, :country_code)).to eq(first)
    end

    it "never overwrites HR's edits when run again" do
      Employee.find_by(employee_code: "EMP000001").update!(designation: "Chief Wizard")
      run_seeds
      expect(Employee.find_by(employee_code: "EMP000001").designation).to eq("Chief Wizard")
    end
  end

  it "is idempotent: running twice creates nothing new" do
    run_seeds
    expect { run_seeds }.not_to change { [ User.count, Department.count, Employee.count ] }
  end
end
