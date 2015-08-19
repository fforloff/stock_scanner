class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :lists
  before_filter :exchanges

  private
  def lists
    @lists = List.all
  end
  def exchanges
    @exchanges = Exchange.all
  end
end
