class ApplicationController < ActionController::Base
	include SessionsHelper
  before_action :set_cache_headers

  def hello
    render html: "hello, world!"
  end

  def letsencrypt
    render text: "#{params[:id]}.#{ENV['LETS_ENCRYPT_KEY']}"
  end

  private

  def set_cache_headers
    response.headers["Cache-Control"] = "no-cache, no-store"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Mon, 01 Jan 1990 00:00:00 GMT"
  end
end