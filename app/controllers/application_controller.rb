class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :get_session_id

  def get_session_id
    @session_id = request.session_options[:id]
    logger.error "SESSION ID #{@session_id}"
  end
end