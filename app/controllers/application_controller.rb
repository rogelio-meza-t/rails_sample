class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :set_locale
  #before_filter :set_notice

  def current_ability
    @current_ability ||= Ability.new(current_tour_operator)
  end
  
  rescue_from CanCan::AccessDenied do |exception|
     puts "Access denied on #{exception.action} #{exception.subject.inspect}"
     redirect_to root_url, :alert => exception.message
  end
  
  def after_sign_in_path_for(resource)
    if resource.is_a?(TourOperator)
      root_path
    else
      super
    end
  end
  
  def sign_in_and_redirect(resource_or_scope, resource)
    
    if resource_or_scope == :tour_operator
      redirect_to calendar_path
    else
      super
    end
  end

  private

  # def set_notice
  #   if current_tour_operator and current_tour_operator.status == 'review'
  #     flash[:alert] = t('notices.account_in_review')
  #   end
  # end
  
  def set_locale
    logger.debug "* Accept-Language: #{request.env['HTTP_ACCEPT_LANGUAGE']}"
    I18n.locale = params[:locale] || locale_from_header || I18n.default_locale
    logger.debug "* Locale set to '#{I18n.locale}'"
  end

  def locale_from_header
    return nil unless accept_language_header
    accept_language_header.scan(/^[a-z]{2}/).first
  end

  def accept_language_header
    request.env['HTTP_ACCEPT_LANGUAGE']
  end
end
