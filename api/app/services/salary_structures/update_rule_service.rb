# Changes one rule's value in a salary structure (e.g. PF 12% -> 10%) and
# audits it, since a rule change alters every breakdown that uses the structure.
module SalaryStructures
  class UpdateRuleService
    def initialize(rule:, value:, user:)
      @rule = rule
      @value = value
      @user = user
    end

    def call
      SalaryStructureComponent.transaction do
        @rule.update!(value: @value)
        Audit::Logger.new(@user).record(@rule, :updated)
      end
      @rule
    end
  end
end
