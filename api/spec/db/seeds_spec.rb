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

  describe "salary structures" do
    before { run_seeds }

    it "creates one standard structure per supported country" do
      expect(SalaryStructure.kept.pluck(:country_code)).to match_array(Country.codes)
    end

    it "gives every structure a valid breakdown for a typical salary" do
      SalaryStructure.includes(rules: %i[salary_component base_component]).find_each do |structure|
        result = Salaries::Calculator.new(annual_salary: 1_200_000, structure:).call
        expect(result[:total_earnings]).to eq(result[:monthly_gross])
      end
    end

    it "never overwrites HR's rule edits when run again" do
      pf = SalaryComponent.find_by!(code: "PF").salary_structure_components.first
      pf.update!(value: 10)
      run_seeds
      expect(pf.reload.value).to eq(10)
    end
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
      EmployeeSalary.delete_all
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

  describe "salary history" do
    before { run_seeds }

    it "gives every employee a joining salary on their joining date" do
      joining = EmployeeSalary.where(change_type: "joining")
      expect(joining.count).to eq(Employee.count)
      expect(joining.includes(:employee).all? { |salary| salary.effective_from == salary.employee.joining_date }).to be(true)
    end

    it "adds raises over the years, in the currency of the employee's country" do
      expect(EmployeeSalary.where(change_type: %w[increment promotion]).count).to be > 0
      expect(EmployeeSalary.includes(:employee).all? { |salary| salary.currency == Country.find(salary.employee.country_code)[:currency] })
        .to be(true)
    end

    it "builds a continuous history: each period ends the day before the next starts" do
      EmployeeSalary.order(:employee_id, :effective_from).group_by(&:employee_id).each_value do |history|
        history.each_cons(2) { |earlier, later| expect(earlier.effective_to).to eq(later.effective_from - 1) }
      end
    end

    it "gives active employees a current salary and ends terminated employees' pay on their exit date" do
      expect(Employee.where(employment_status: "active").includes(:current_salary).all?(&:current_salary)).to be(true)
      Employee.where(employment_status: "terminated").includes(:employee_salaries).find_each do |employee|
        expect(employee.employee_salaries.max_by(&:effective_from).effective_to).to eq(employee.exit_date)
      end
    end

    it "creates only salaries that pass every model validation" do
      expect(EmployeeSalary.includes(:employee, :salary_structure).reject(&:valid?)).to be_empty
    end

    it "never adds seed salaries to an employee who already has salary history" do
      employee = Employee.first
      EmployeeSalary.where(employee:).delete_all
      create(:employee_salary, employee:, effective_from: employee.joining_date, currency: "INR")
      run_seeds
      expect(employee.employee_salaries.count).to eq(1)
    end
  end

  it "is idempotent: running twice creates nothing new" do
    run_seeds
    expect { run_seeds }.not_to change {
      [ User.count, Department.count, Employee.count, SalaryComponent.count, SalaryStructure.count,
        SalaryStructureComponent.count, EmployeeSalary.count ]
    }
  end
end
