class Documents::CreateInteractor < ApplicationInteractor
  delegate :params,
           :user,
           :document,
           :document_type_selection,
           to: :context
  def call
    context.document_type_selection = params[:document_type_selection]
    check_for_issues
    create_document
  end

private
  def check_for_issues
    issues = Requirements::Issues.new
    issues.create(:document_type_selection, :not_selected) unless document_type_selection

    context.fail!(issues:) if issues.any?
  end

  def create_document
    context.document = CreateDocumentService.call(
      document_type_id: document_type_selection, user:
    )    
  end
end