class ApplicationController < ActionController::API
  include ActionController::Cookies
  include ActionController::RequestForgeryProtection

  private

  def t(key, options = {})
    I18n.t(key, **{ scope: i18n_scope }.merge(options))
  end

  def i18n_scope
    controller_name.to_sym
  end
end