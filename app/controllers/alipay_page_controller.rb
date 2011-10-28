
#require 'xml/libxml'
require 'net/http'
require 'uri'
require 'lib/alipay'

class AlipayPageController < ApplicationController
	
  before_filter :require_admin_login, :only => []
	
  def getDataForXMLMatch(res_data, node)
    result = res_data.match(/\<#{node}\>(.*)\<\/#{node}\>/)
    if result
      return result[1]
    else
      return nil
    end
  end

	
	
	def notify_page
	  puts 'params.inspect in line 22'
	  puts params.inspect
	  result = SyAlipay.notify_page(params)
	  notify_data = URI.decode(params[:notify_data])
    if notify_data
      out_trade_no = getDataForXMLMatch(notify_data, 'out_trade_no') 
    end
	  if result && out_trade_no
	    
      trade_status = getDataForXMLMatch(notify_data, 'trade_status') # TRADE_FINISHED
      
	    puts 'notify_data.inspect in line 30'
      puts notify_data.inspect
      
      # ==================================
      buyer_email = getDataForXMLMatch(notify_data, 'buyer_email') 
      trade_no = getDataForXMLMatch(notify_data, 'trade_no')
      buyer_id = getDataForXMLMatch(notify_data, 'buyer_id')
      # ==================================

      errno = 0
      partner = getDataForXMLMatch(notify_data, 'seller_id') #partner
      if partner != PARTNER	#合作身份者ID，以2088开头的16位纯数字
        errno += 1
      end
      seller_email = getDataForXMLMatch(notify_data, 'seller_email') 
      if seller_email	!= SELLEREMAIL	#签约支付宝账号或卖家支付宝帐户
        errno += 1
      end
      
	    if !order_list 
	      errno += 0
	    elsif !(ShoppingList.state_str[order_list.state] == 'wait_for_payment' )#|| ShoppingList.state_str[order_list.state] == 'init')
        errno += 0
      end
      
      total_fee = getDataForXMLMatch(notify_data, 'total_fee')
      if total_fee.to_f != order_list.total_fee
        errno += 1
      end
      ip_add = request.remote_ip
      
        add_arr = ip_add.split('.')
        if add_arr[0] == '121' && add_arr[1] == '0'
          if add_arr[2].to_i >= 26 && add_arr[2].to_i <= 27
            puts 'ok'
          else
            errno += 1
          end
        elsif add_arr[0] == '110' && add_arr[1] == '75'
          if add_arr[2].to_i >= 128 && add_arr[2].to_i <= 159
            puts 'ok'
          else
            errno += 1
          end
        end
              
        #121.0.26.0/23（IP范围：121.0.26.1----121.0.27.254）

        #110.75.128.0/19（IP范围：110.75.128.1——110.75.159.254）

      if trade_status == 'TRADE_FINISHED' && errno == 0#params[:result] == 'success'
  	    save_and_notify(order_list.id)
      end
    end
  end
  
  def return_page
    #result = SyAlipay.return_page(params)
    #out_trade_no = params[:out_trade_no]
	  #if result && out_trade_no
	  #  errno = 0
	  #  order_list_id = out_trade_no[4,6].to_i
	  #  trade_status = params[:result]
	    
	    # ==================================
	  #  trade_no = params[:trade_no]
	    # ==================================
	    
	  #  if trade_status == 'success' && errno == 0
	      #save_and_notify(order_list.id)
    #  end
	  #end
  end
  
  def save_and_notify(list_id)
    order_list = ShoppingList.find_by_id(list_id)
    if order_list
      order_list.state = ShoppingList.state['payed']
      order_list.save
    end
  end
end
