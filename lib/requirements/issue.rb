module Requirements
  class Issue
    attr_accessor :field, :issue_key, :context

    def initialize(field, issue_key, **context)
      @field = field.to_sym
      @issue_key = issue_key
      @context = context
    end

    def message
      I18n.t("requirements.#{field}.#{issue_key}.message", **context)
    end
  end
end