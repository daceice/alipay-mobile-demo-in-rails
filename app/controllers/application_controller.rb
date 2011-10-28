class ApplicationController < ActionController::Base
  protect_from_forgery
  
  
  before_filter :require_admin_login
  
  def notify_success(content)
    flash[:notice] = content
    flash[:error] = ''
    session[:notice] = content
  end
  
  def notify_failure(content)
    flash[:error] = content
    flash[:notice] = ''
    session[:notice] = content
  end
  
  # ==================================
  
  def return_to_return_to(backup_path, return_url = nil)
    if return_url && return_url != nil && return_url != ''
      return_to = return_url
    elsif session[:return_to]
      return_to = session[:return_to]
      session[:return_to] = nil
    else
      return_to = backup_path
    end
    redirect_to return_to
  end
  
  # ==================================

  def fetch_current_admin
    current_admin = Admin.find_by_id(session[:admin_id])
    if current_admin #&& current_admin.available
      return current_admin
    else
      return nil
    end
  end
  
  def require_admin_login
    if params[:controller] != 'session' && params[:controller] != 'wap_purchases' && params[:controller] != 'alipay_page'
      @current_admin = fetch_current_admin
      if @current_admin == nil
        if request.get?
          return_url = request.url
        else
          return_url = request.referer
        end
        redirect_to session_new_url(:return_url => return_url)
      end
    end
  end
  
  def require_super_login
    if params[:controller] != 'session'
      @current_admin = fetch_current_admin
      if @current_admin == nil || @current_admin.id != 1
        if request.get?
          return_url = request.url
        else
          return_url = request.referer
        end
        redirect_to new_session_url(:return_url => return_url)
      end
    end
  end
  
  # ==================================
  
  def product_icon_image(product)
    if product && product.info && product.info.image
      return image_tag product.info.image.url(:icon)
    else
      return nil
    end
  end
  
  def product_image(product)
    if product && product.info && product.info.image
      return image_tag product.info.image.url
    else
      return nil
    end
  end
end
