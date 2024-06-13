class DocumentType::TitleAndBasePathField
  def id
    "title_and_base_path"
  end

  def publish_issues(_edition)
    Requirements::Issues.new
  end    
end
