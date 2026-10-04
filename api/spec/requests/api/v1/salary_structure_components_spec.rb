require "rails_helper"

RSpec.describe "PATCH /api/v1/salary_structures/:salary_structure_id/components/:id", type: :request do
  let(:headers) { auth_headers_for(create(:user)) }
  let(:structure) { create(:salary_structure) }
  let!(:basic) { add_rule(structure, "BASIC", :percentage_of_gross, 50) }
  let!(:special) { add_rule(structure, "SPECIAL", :remainder) }
  let!(:pf) { add_rule(structure, "PF", :percentage_of_component, 12, type: :deduction, base: "BASIC") }

  def update_rule(rule, structure_id: structure.id, **attributes)
    patch "/api/v1/salary_structures/#{structure_id}/components/#{rule.id}",
          params: { component: attributes }, headers: headers, as: :json
  end

  it "requires a signed-in user" do
    patch "/api/v1/salary_structures/#{structure.id}/components/#{pf.id}", as: :json
    expect(response).to have_http_status(:unauthorized)
  end

  it "changes the rule's value, e.g. PF from 12% to 10%" do
    update_rule(pf, value: 10)
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body["data"]["value"]).to eq("10.0")
    expect(pf.reload.value).to eq(10)
  end

  it "records the change in the audit log" do
    update_rule(pf, value: 10)
    expect(AuditLog.last).to have_attributes(action: "updated", auditable: pf,
                                             change_set: { "value" => [ "12.0", "10.0" ] })
  end

  it "changes only the value, never the calculation method or position" do
    update_rule(pf, value: 10, calculation_method: "fixed", position: 99)
    expect(pf.reload).to have_attributes(calculation_method: "percentage_of_component", position: 3)
  end

  it "returns 422 for an invalid value" do
    update_rule(pf, value: 150)
    expect(response).to have_http_status(:unprocessable_content)
    expect(response.parsed_body["details"]).to have_key("value")

    update_rule(special, value: 10)
    expect(response).to have_http_status(:unprocessable_content)
  end

  it "returns 404 for a rule of another structure or a soft-deleted rule" do
    update_rule(pf, structure_id: create(:salary_structure).id, value: 10)
    expect(response).to have_http_status(:not_found)

    pf.soft_delete!
    update_rule(pf, value: 10)
    expect(response).to have_http_status(:not_found)
  end
end
