class ApplicationController < ActionController::Base
  include PublishingPlatform::SSO::ControllerMethods
  before_action :authenticate_user!
end
