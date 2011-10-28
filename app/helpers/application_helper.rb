module ApplicationHelper
  def demo_helper
    return 'this is demo'
  end
  
  
  def show_error
    result = flash[:error]
    flash[:error] = ''
    result
  end
  
  def show_notice
    result = flash[:notice]
    flash[:notice] = ''
    result
  end
  
  # ==================================
  
  def ava_to_s(available)
    if available
      return '可用'
    else
      return '不可用'
    end
  end
  
  def bool_to_s(available)
    if available
      return '是'
    else
      return '否'
    end
  end
  
  # ==================================
  
  
  def shift_time(time_to_shift)
    if time_to_shift
      return time_to_shift.strftime('%Y-%m-%d %H:%M:%S')
    else
      return ''
    end
  end
  
  def shift_date(time_to_shift)
    if time_to_shift
      return time_to_shift.strftime('%Y-%m-%d')
    else
      return ''
    end
  end
  
  # ==================================
  
  def super_login
    current_admin = Admin.find_by_id(session[:admin_id])
    if current_admin == nil || current_admin.id != 1
      return false
    else
      return true
    end
    
  end
  
  # ==================================
  
  
  def paging(path, count, limit = 20, params = {}, break_signal = ' ')
    result = ''
    result += '共' + (((count - 1)/limit) + 1).to_s + '页 '
    result += page_icon( path, count, limit, params, break_signal)
    return result
  end
  
  def page_admin(path, count, limit = 20, params = {}, break_signal = ' ')
    result = ''
    result += '共' + count.to_s + '条 '
    result += page_icon( path, count, limit, params, break_signal)
    return result
  end
  
end
