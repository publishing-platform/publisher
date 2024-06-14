class DocumentType::SummaryField
  SUMMARY_MAX_LENGTH = 600

  def id
    "summary"
  end

  def updater_params(_edition, params)
    { summary: params[:summary]&.strip }
  end

  def form_issues(_edition, params)
    issues = Requirements::Issues.new

    if params[:summary].to_s.size > SUMMARY_MAX_LENGTH
      issues.create(:summary, :too_long, max_length: SUMMARY_MAX_LENGTH)
    end

    if params[:summary].to_s.lines.count > 1
      issues.create(:summary, :multiline)
    end

    issues
  end

  def publish_issues(edition)
    issues = Requirements::Issues.new
    issues.create(:summary, :blank) if edition.summary.blank?
    issues
  end
end
