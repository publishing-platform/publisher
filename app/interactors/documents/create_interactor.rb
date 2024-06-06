class Documents::CreateInteractor < ApplicationInteractor
  delegate :params,
           :user,
           :document,
           :document_type,
           :document_types,
           to: :context
  def call
    find_selection
    
    check_for_issues
    create_document
  end

private
  def find_selection
    context.document_types = DocumentType.all
    context.document_type = params[:document_type]
  end

  def check_for_issues
    issues = Requirements::Issues.new
    issues.create(:document_type, :not_selected) unless document_type

    context.fail!(issues:) if issues.any?
  end

  def create_document
    context.document = CreateDocumentService.call(
      document_type_id: document_type, user:
    )    
  end
end