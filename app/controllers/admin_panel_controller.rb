class AdminPanelController < ApplicationController
  def index
  end
  
  def change_psw
    @admin = @current_admin
  end
  
  def change_psw_up
    status = false
    current_admin = Admin.authenticate(@current_admin.login_name, params[:plain_password])
    if @current_admin && params[:new_password] && params[:new_password] != ''
      current_admin.plain_password = params[:new_password]
      current_admin.encrypt
      status = current_admin.save
    end
    if status
      notify_success('change password success')
      redirect_to admin_panel_index_url
    else
      notify_failure('change password failure')
      redirect_to admin_panel_change_psw_url
    end
  end

end
