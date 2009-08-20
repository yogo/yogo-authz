class YogoAuthz::UserSessionsController < ApplicationController
  unloadable
  
  # before_filter :require_no_user, :only => [:new, :create]
  # before_filter :require_user, :only => :destroy
  
  require_user    :for => :destroy
  require_no_user :for => [:new, :create]
  # authorize_group :default
  
  def new
    # debugger
    @user_session = YogoAuthz::UserSession.new
  end
  
  def create
    @user_session = YogoAuthz::UserSession.new(params[:yogo_authz_user_session])
    if @user_session.save
      flash[:notice] = "Login successful!"
      redirect_back_or_default '/'
    else
      render :action => :new
    end
  end
  
  def destroy
    current_user_session.destroy
    flash[:notice] = "Logout successful!"
    redirect_back_or_default new_user_session_url
  end
  
end
