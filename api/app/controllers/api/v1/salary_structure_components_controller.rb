# Lets HR change one rule's value in a structure (e.g. PF from 12% to 10%).
# Only the value is editable; the structure's shape comes from seeds.
module Api
  module V1
    class SalaryStructureComponentsController < ApplicationController
      def update
        rule = SalaryStructure.kept.find(params[:salary_structure_id]).rules.find(params[:id])
        value = params.expect(component: [ :value ])[:value]
        SalaryStructures::UpdateRuleService.new(rule:, value:, user: current_user).call
        render_record(rule, serializer: SalaryStructureComponentSerializer)
      end
    end
  end
end
