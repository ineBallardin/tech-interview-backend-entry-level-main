class ApplicationController < ActionController::API
  include ActionController::Cookies
  include ActionController::RequestForgeryProtection

  before_action :set_session_cookie

  private

  def set_session_cookie
    cookies["_cart_session"] ||= {
      value: SecureRandom.hex(16),
      httponly: true,
      secure: Rails.env.production?
    }
  end
end