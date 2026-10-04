require "rails_helper"

RSpec.describe ErrorHandling, type: :controller do
  controller(ApplicationController) do
    skip_before_action :authenticate_user!

    def index
      case params[:case]
      when "not_found" then User.find(0)
      when "invalid" then User.create!(name: "")
      when "missing_param" then params.require(:user)
      when "domain" then raise DomainError, "Overlaps an existing salary"
      when "unexpected" then raise "boom"
      end
    end
  end

  before { stub_const("DomainError", Class.new(ApplicationError) { def status = :conflict }) }

  def body = response.parsed_body

  it "renders 404 for a missing record" do
    get :index, params: { case: "not_found" }
    expect(response).to have_http_status(:not_found)
    expect(body).to include("code" => "not_found", "error" => a_string_including("User"))
  end

  it "renders 422 with field details for an invalid record" do
    get :index, params: { case: "invalid" }
    expect(response).to have_http_status(:unprocessable_content)
    expect(body["code"]).to eq("record_invalid")
    expect(body["details"]).to include("name", "email", "password")
  end

  it "renders 400 for a missing required parameter" do
    get :index, params: { case: "missing_param" }
    expect(response).to have_http_status(:bad_request)
    expect(body["code"]).to eq("parameter_missing")
  end

  it "renders a domain error with its own status, code and message" do
    get :index, params: { case: "domain" }
    expect(response).to have_http_status(:conflict)
    expect(body).to include("error" => "Overlaps an existing salary", "code" => "domain_error")
  end

  it "logs every handled error as a warning" do
    allow(Rails.logger).to receive(:warn)
    get :index, params: { case: "not_found" }
    expect(Rails.logger).to have_received(:warn).with(a_string_including("not_found"))
  end

  describe "unexpected errors" do
    it "renders a generic 500 without leaking internals" do
      get :index, params: { case: "unexpected" }
      expect(response).to have_http_status(:internal_server_error)
      expect(body).to eq("error" => "Something went wrong", "code" => "internal_server_error", "details" => {})
    end

    it "logs the error with its backtrace" do
      allow(Rails.logger).to receive(:error)
      get :index, params: { case: "unexpected" }
      expect(Rails.logger).to have_received(:error).with(a_string_including("RuntimeError", "boom", "error_handling_spec.rb"))
    end

    it "reports the error to error tracking" do
      allow(Rails.error).to receive(:report)
      get :index, params: { case: "unexpected" }
      expect(Rails.error).to have_received(:report).with(an_instance_of(RuntimeError), handled: false)
    end
  end
end
