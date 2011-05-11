class ApplicationController < ActionController::Base
  protect_from_forgery

  helper :all

  before_filter :authenticate_user!,
    :get_bitcoin_client,
    :move_xml_params,
    :set_locale,
    :set_time_zone

  def get_bitcoin_client
    @bitcoin = Bitcoin::Client.new
  end

  def set_time_zone
    if current_user and !current_user.time_zone.blank?
      Time.zone = ActiveSupport::TimeZone[current_user.time_zone]
    end
  end

  # Changes the locale if *locale* (en|fr|...) is passed as GET parameter
  def set_locale
    # TODO : Try to guess locale with IP lookup and/or HTTP headers
    locale = params[:locale] or session[:locale] or "en"
    locale = locale.to_sym if locale

    if locale and I18n.available_locales.include?(locale)
      I18n.locale = locale
      session[:locale] = locale
    end
  end
  
  # This method is used to work around the fact that there is only
  # one allowed root node in a well formed XML document, we remove
  # the root node so we get to pretend that XML === JSON
  def move_xml_params
    if request.content_type =~ /xml/
      params.merge! params.delete(:api)
    end
  end
end
