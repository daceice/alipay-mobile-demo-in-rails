
#require 'libxml/xml'
require 'net/http'
require 'uri'
require 'lib/alipay'

class AlipayPageDemoController < ApplicationController
	
	#def notify_page
	#  result = SyAlipay.notify_page(params)
	#  out_trade_no = params[:out_trade_no]
	#  if out_trade_no
	#    order_list_id = out_trade_no[4,6].to_i
	#    order_list = ShoppingList.find_by_id(order_list_id)
	#    if order_list && order_list.state == 'init'
	#      order_list.state = 'payed'
	#      order_list.save
  #    end
  #  end
  #end
  
  # 得到支付链接
  def get_page
    
    # 变参
    partner		    = PARTNER	#合作身份者ID，以2088开头的16位纯数字
    key   	  		= KEY	#安全检验码，以数字和字母组成的32位字符
    seller_email	= SELLEREMAIL	#签约支付宝账号或卖家支付宝帐户
    notify_url		= NOTIFYURL	#异步返回消息通知页面，用于告知商户订单状态
    call_back_url	= CALLBACKURL	#同步返回消息通知页面，用于提示商户订单状态
    merchant_url	= "http://"	#网站商品的展示地址
    subject   		= "测试"	#产品名称
    out_trade_no	= '001100' + DateTime.now.strftime('%Y%m%d%H%M%S')	#请与贵网站订单系统中的唯一订单号匹配
    total_fee 		= "0.01"	#订单总金额，显示在支付宝收银台里的“应付总额”里
    out_user  		= "1111"	#外部商号，买家的唯一标示
    
    # ==================================
    
    # 固参
    
    service1		= "alipay.wap.trade.create.direct"	#接口1
    service2		= "alipay.wap.auth.authAndExecute"	#接口2
    format			= "xml"							#http传输格式
    sec_id			= "MD5"							#签名方式 不需修改
    _input_charset	= "utf-8"							#字符编码格式
    v			    	= "2.0"							#版本号
    
    # ==================================
    
    #构造要请求的参数数组，无需改动
    pms1 = {}
    pms1['call_back_url'] = call_back_url
    pms1['req_data'] = '<direct_trade_create_req><subject>' + subject + 
      '</subject><out_trade_no>' + out_trade_no + '</out_trade_no><total_fee>' +
      total_fee + "</total_fee><seller_account_name>" + seller_email +
  	  "</seller_account_name><notify_url>" + notify_url + "</notify_url><out_user>" + 
  	  out_user + "</out_user><merchant_url>" + merchant_url + "</merchant_url></direct_trade_create_req>"  
    pms1['service'] = service1
    pms1['sec_id'] = sec_id
    pms1['partner'] = partner
    pms1['req_id'] = DateTime.now.strftime('%Y%m%d%H%M%S')#date("Ymdhms") #
    pms1['format'] = format
    pms1['v'] = v
    
    #puts 'get_page pms1'
    #puts pms1.inspect
    
    result = alipay_wap_trade_create_direct(pms1,key,sec_id)
    token = result[:token]
    
    
    values = {}#result[:values]
    values[:gateway] = "http://wappaygw.alipay.com/service/rest.htm?"	#网关地址
    
    # ==================================
    
    #构造要请求的参数数组，无需改动
    
    if token
      pms2 = {}
      pms2['req_data'] = "<auth_and_execute_req><request_token>" + token.to_s +
        "</request_token></auth_and_execute_req>"
      pms2['service'] = service2  
      pms2['sec_id'] = sec_id
      pms2['partner'] = partner  
      pms2['call_back_url'] = call_back_url
      pms2['format'] = format
      pms2['v'] = v
    
      #puts '# ================================== before last'
      #puts pms2.inspect
      puts 'pms2!!!!!'
      puts pms2.inspect
      result = alipay_Wap_Auth_AuthAndExecute(pms2, key, values)
      #puts 'result # =================================='
      #puts result
      @myurl = result
      #puts @myurl
      #return result
    else
      return false
    end

  end  
  
  def alipay_wap_trade_create_direct(parameter,key,sign_type)
    values = {}
    
    values[:gateway] = "http://wappaygw.alipay.com/service/rest.htm?"	#网关地址
    values[:_key] = ''
    values[:mysign] = ''
    values[:sign_type] = ''
    values[:parameter] = ''
    values[:format] = ''
    values[:req_data] = ''
    
    values[:_key] = key
    values[:sign_type] = sign_type
    values[:parameter] = para_filter(parameter)
    #puts 'puts 1 # =================================='
    #puts values[:parameter].inspect
    #puts 'end # =================================='
    values[:req_data] = parameter['req_data']
    values[:format] = values[:parameter]['format']
    sort_array = arg_sort(values[:parameter]) #
    
    #puts 'puts 2 # =================================='
    #puts sort_array.inspect
    #puts 'end # =================================='
    
    values[:mysign] = build_mysign(sort_array, values[:_key], values[:sign_type]) #
    values[:req_data]	= create_linkstring(values[:parameter]) + '&sign=' + 
      URI.escape(values[:mysign])
    #puts 'alipay_wap_trade_create_direct values'
    #puts values.inspect
    
    result = post(values)
    return getToken(URI.decode(result), values)
  end
  
  def para_filter(parameter)  #除去数组中的空值和签名模式
		para = {}
		
		parameter.keys.each do |key|
			if !(key == "sign" || key == "sign_type" || parameter[key] == "")
				para[key] = parameter[key]
			end
		end
		return para
	end
	
  # sort key
  def arg_sort(array)
    return array
  end
  
	def build_mysign(sort_array, key, sign_type = "MD5")
	  
    #puts 'puts 3 # =================================='
    #puts sort_array.inspect
    #puts 'end # =================================='
    
    puts 'in build sigh'
    puts sort_array.inspect
    #puts key
	  
	  prestr = create_linkstring(sort_array)     	#把数组所有元素，按照“参数=参数值”的模式用“&”字符拼接成字符串
    prestr = prestr + key   							      #把拼接后的字符串再与安全校验码直接连接起来
    mysgin = sign(prestr, sign_type)    			  #把最终的字符串签名，获得签名结果
    return mysgin
  end
  
  def create_linkstring(array) #sort_array
    
    #puts 'puts 4 # =================================='
    #puts array.inspect
    #puts array.keys.inspect
    #puts array.keys.sort.inspect
    #puts 'end # =================================='
    
    
    arg = "";
    array.keys.sort.each do |key|
      arg += (key + '=' + (array[key]) + '&')
      puts key
      puts array[key]
		end
		arg = arg[0, arg.length - 1] #edit!
		puts arg.inspect
		return arg
  end
  
  # 构建签名
	def sign(prestr, sign_type) 
	  puts 'begin sign!'
	  puts prestr
		sign = ""
		if(sign_type == 'MD5') 
			sign = Digest::MD5.hexdigest(prestr)
		elsif (sign_type == 'DSA') 
			#DSA 签名方法待后续开发
			puts("DSA 签名方法待后续开发，请先使用MD5签名方式")
		else 
			puts("支付宝暂不支持" + sign_type + "类型的签名方式")
		end
		return sign
	end
  
  def post(values)
    #puts 'in post'
    #puts values.inspect
    #puts values[:gateway]
    #puts '# =================================='
    #values.keys.each do |key|
    #  puts key
    #  puts values[key]
    #end
    
    #req = Net::HTTP::Post.new(URI.parse(values[:gateway] + values[:req_data])
    #values[:parameter][:sign] = values[:mysign]
    #res = Net::HTTP.post_form(URI.parse(values[:gateway] ), values[:parameter])
    #http = Net::HTTP::Post.new(URI.parse(values[:gateway]))
    #res = http.post(URI.parse(values[:gateway]), values[:req_data])
    url = URI.parse(values[:gateway])
    req = Net::HTTP::Post.new(url.path)
    req.body = values[:req_data]
    res = Net::HTTP.start(url.host, url.port) { |http| http.request(req) }
    data = res.body
    #puts 'date'
    
    #puts res
    #puts data.inspect
    puts 'in post'
    puts values[:req_data].inspect
    puts data.inspect
    return data
  end
  
  def getToken(result, values)
    #puts 'in get token'
    #result = URI.escape(result)   				#URL转码
    arr = result.split('&')			        	#根据 & 符号拆分
    temp = {}							                #临时存放拆分的数组
  	my_array = {}           						  #待签名的数组
  	#循环构造key、value数组
  	
	  puts 'before'
  	0.upto arr.count do |i|
  	  #temp = explode( '=' , arr[i] , 2 );
  	  #temp = arr[i].split('=')
  	  temp = []
  	  #puts 'in get token loop'
  	  #puts arr[i].inspect
  	  if arr[i]
    	  index = arr[i].index('=')
    	  length = arr[i].length
    	  temp << arr[i][0,index]
    	  temp << arr[i][index + 1, length - index - 1]
    		my_array[temp[0]] = temp[1]
    		puts temp[1]
  		end
  	end
#  	sign = my_array['sign'];												#支付宝返回签名
#  	puts 'in get token'
#  	puts my_array.inspect
#  	my_array = para_filter(my_array);								#拆分完毕后的数组
#    sort_array = arg_sort(my_array);								#排序数组
    #puts my_array.inspect
  	#puts sort_array.inspect
#    values[:mysign] = build_mysign(sort_array, values[:_key],values[:sign_type])
    #造本地参数签名，用于对比支付宝请求的签名
    #puts ';;;;;;;;;;;;;;;;;;;;;;;;;;;  in get toke  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;'
    #puts my_array['res_data']
    #puts ';;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;'
#    puts values[:mysign]
#    puts sign
#    puts 'xxxxxxx'
#    if values[:mysign] == sign
      token = getDataForXML(my_array['res_data'],'/direct_trade_create_res/request_token');	#返回token
		  return { :token => token, :values => values }
#		else
		  puts("签名不正确")
#		  return { :success => false, :message => '签名不正确', :values => values }
#	  end
  end
  
  def getDataForXML(res_data, node)
    #puts ';;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;'
    #puts res_data
    #puts ';;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;'
    if res_data
      result = res_data.match(/\<request_token\>(.*)\<\/request_token\>/)
      if result
        return result[1]
      else
        return nil
      end
    else
      return nil
    end
  end
  
  def alipay_Wap_Auth_AuthAndExecute(parameter, key, values)
    #puts '# ================================== in last'
    #puts parameter.inspect
    #puts values.inspect
    #puts values[:parameter].inspect
    puts parameter.inspect
    values[:parameter] = para_filter(parameter)
    #puts values[:parameter].inspect
		sort_array = arg_sort(values[:parameter])
		values[:sign_type] = values[:parameter]['sec_id']
		values[:_key] = key
		values[:mysign] = build_mysign(sort_array, values[:_key],values[:sign_type])
    redirect_url = values[:gateway] + create_linkstring(values[:parameter]) + 
      '&sign=' + URI.escape(values[:mysign])
    #puts 'redirect_url # =================================='
    #puts redirect_url
    return redirect_url
    #redirect_to redirect_url
  end    
  
  
  # ==================================
  
  
  def return_page
    
  end
  
  def notify_page
    
    # 变参
    partner		    = PARTNER	#合作身份者ID，以2088开头的16位纯数字
    key   	  		= KEY	#安全检验码，以数字和字母组成的32位字符
    seller_email	= SELLEREMAIL	#签约支付宝账号或卖家支付宝帐户
    notify_url		= NOTIFYURL	#异步返回消息通知页面，用于告知商户订单状态
    call_back_url	= CALLBACKURL	#同步返回消息通知页面，用于提示商户订单状态
    merchant_url	= "http://"	#网站商品的展示地址
    subject   		= "测试"	#产品名称
    # slip_code
    out_trade_no	= '001100' + DateTime.now.strftime('%Y%m%d%H%M%S')	#请与贵网站订单系统中的唯一订单号匹配
    total_fee 		= "0.01"	#订单总金额，显示在支付宝收银台里的“应付总额”里
    # user_id
    out_user  		= "1111"	#外部商号，买家的唯一标示
    
    # ==================================
    
    # 固参
    
    service1		= "alipay.wap.trade.create.direct"	#接口1
    service2		= "alipay.wap.auth.authAndExecute"	#接口2
    format			= "xml"							#http传输格式
    sec_id			= "MD5"							#签名方式 不需修改
    _input_charset	= "utf-8"							#字符编码格式
    v			    	= "2.0"							#版本号
    
    values = {}
    values[:gateway] = "http://wappaygw.alipay.com/service/rest.htm?"
    values[:partner] = partner
    values[:_key] = key
    values[:mysign] = ''
    values[:sign_type] = sign_type
    values[:_input_charset] = _input_charset
    
    verify_result = return_verify(values)
    
    if verify_result
      my_out_trade_no = params[:out_trade_no]
      my_result = params[:result]
      # return the trade no of alipay system
      my_trade_no = params[:trade_no]
      if params[:result] == 'success'
        # add code success here
      else        
        # add code fail here
      end
    else
      
    end
  end
  
  def return_verify(values)
    if (params == nil)
      return false
    else
      get = para_filter(params)
      sort_get = arg_sort(params)
      values[:mysign] = build_mysign(sort_get, values[:_key], values[:sign_type])
      if values[:mysign] == params[:sign]
        return true
      else
        return false
      end
    end
  end
  
  
end
