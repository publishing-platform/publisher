class DocumentType::BodyField
  def id
    "body"
  end

  def publish_issues(_edition)
    Requirements::Issues.new
  end
end
