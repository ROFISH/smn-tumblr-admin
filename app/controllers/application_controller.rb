class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :login_to_fangamer, if:->(x){ session[:username].blank? || session[:last_login].try(:<,24.hours.ago)}, except: [:fangamer_callback]
  before_action :require_user, except: [:fangamer_callback]
  before_action :set_client, except: [:fangamer_callback]

  def login_to_fangamer
    redirect_to 'https://secure.fangamer.com/login/multipass?key=smn-tumblr-admin.herokuapp.com'
  end

  def require_user
    if !User.exists?(name:session[:username])
      render text:'Nothing to see here. Please move along.'
    end
  end

  def set_client
    #@client = Tumblr::Client.new oauth_token:session[:oauth_token], oauth_token_secret:session[:oauth_secret]
    @client = Tumblr::Client.new
  end
end
