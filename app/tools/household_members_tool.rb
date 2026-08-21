class HouseholdMembersTool < RubyLLM::Tool
  description "Returns the number of members in the household."

  def initialize(household:)
    @household = household
  end

  def execute
    @household.members.count
  end
end
