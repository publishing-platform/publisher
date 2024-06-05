class DocumentsController < ApplicationController
  def index
    @editions = []
  end

  def new    
  end

  def create
    issues = Requirements::Issues.new

    if(!params[:document_type_selection])
      issues.create(:document_type_selection, :not_selected)
      
      render :new,
        assigns: { issues: },
        status: :unprocessable_entity      
    end
  end
end