class DocumentType::SummaryField
  def id
    "summary"
  end

  def publish_issues(_edition)
    Requirements::Issues.new
  end
end
