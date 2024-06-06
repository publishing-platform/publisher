class DocumentsController < ApplicationController
  def index
    @editions = Edition.all
    @filter_params = filter_params

    filter_editions
    order_editions
  end

  def show
    @edition = Edition.find_current(params[:id])
  end  

  def new 
    @document_types = DocumentType.all
  end

  def create
    result = Documents::CreateInteractor.call(params:, user: current_user)

    if result.success?
      redirect_to edition_path(result.document)
    else
      render :new,
        assigns: { 
          issues: result.issues, 
          document_type: result.document_type, 
          document_types: result.document_types 
        },
        status: :unprocessable_entity
    end
  end

private

  def filter_editions
    @editions = Edition.where(current: true)
    @editions = @editions.where("editions.title like ? OR editions.base_path like ?", 
                            "%#{@filter_params[:title_or_url]}%", 
                            "%#{@filter_params[:title_or_url]}%") if @filter_params[:title_or_url].present?
    @editions = @editions.where(document_type_id: @filter_params[:document_type]) if @filter_params[:document_type].present?
    @editions = @editions.where(state: @filter_params[:state]) if @filter_params[:state].present?
  end

  def order_editions
    @editions = @editions.order(updated_at: :desc)
  end  

  def filter_params
    params.permit(:title_or_url, :document_type, :state)
  end
end