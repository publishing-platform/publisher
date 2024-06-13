class ApplicationController < ActionController::Base
  include PublishingPlatform::SSO::ControllerMethods
  include EditionAssertions
  
  before_action :authenticate_user!

  rescue_from EditionAssertions::StateError do |e|
    Rails.logger.warn(e.message)
    redirect_to document_path(e.edition.document)
  end  
end
