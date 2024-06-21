class DocumentType::BodyField
  def id
    "body"
  end

  def updater_params(_edition, params)
    { contents: { body: params[:body] } }
  end

  def form_issues(_edition, _params)
    Requirements::Issues.new
  end

  def preview_issues(_edition)
    Requirements::Issues.new
  end  

  def publish_issues(edition)
    issues = Requirements::Issues.new

    issues.create(id, :blank) if edition.contents[id].blank?
    issues
  end
end
