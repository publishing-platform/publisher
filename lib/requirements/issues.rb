module Requirements
  class Issues
    include Enumerable

    delegate :each, :empty?, to: :issues
    attr_reader :issues

    def initialize(issues = [])
      @issues = issues
    end

    def push(*issues)
      self.issues.push(*issues)
    end

    def create(...)
      issues << Issue.new(...)
    end

    def items(params = {})
      map { |issue| issue.to_item(**issue_item_params(issue, params)) }
    end

    def items_for(field)
      select { |issue| issue.field == field }
    end

    def has_key?(field)
      any? { |issue| issue.field == field }
    end
  end
end
