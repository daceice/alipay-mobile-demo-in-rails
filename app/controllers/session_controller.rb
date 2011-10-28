class SessionController < ApplicationController
  
  before_filter :require_admin_login, :only => []
  
  def new
    admin = fetch_current_admin
    if admin != nil
      redirect_to admin_panel_index_url
    end
  end
  
  def create
    #puts params[:plain_password]
    @current_admin = Admin.authenticate(params[:login_name], params[:plain_password])
    if @current_admin != nil
      session[:admin_id] = @current_admin.id
      notify_success('')
      respond_to do |format|
        format.html { return_to_return_to(admin_panel_index_url, params[:return_url]) }
      end
    else
      respond_to do |format|
        notify_failure('登陆失败，用户名或密码错误。')
        format.html { 
          render :action => 'new', :return_url => params[:return_url], :login_name => params[:login_name], :password => params[:plain_password]
        }
      end
    end
  end
  
  def destroy
    session[:admin_id] = nil
    redirect_to session_new_url
  end
end
