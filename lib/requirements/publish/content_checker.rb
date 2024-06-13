class Requirements::Publish::ContentChecker
  include Requirements::Checker

  attr_reader :edition

  def initialize(edition)
    @edition = edition
  end

  def check
    edition.document_type.contents.each do |field|
      issues.push(*field.publish_issues(edition))
    end
  end
end
