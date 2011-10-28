#require 'xml/libxml'
require 'net/http'
require 'uri'

class SyAlipay
  
  def self.alipay_wap_trade_create_direct(parameter,key,sign_type)
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
    values[:parameter] = self.para_filter(parameter)
    values[:req_data] = parameter['req_data']
    values[:format] = values[:parameter]['format']
    sort_array = self.arg_sort(values[:parameter]) #
    
    values[:mysign] = self.build_mysign(sort_array, values[:_key], values[:sign_type]) #
    values[:req_data]	= self.create_linkstring(values[:parameter]) + '&sign=' + 
      (values[:mysign])
    
    result = self.post(values)
    return self.getToken(URI.decode(result), values)
  end
  
  def self.para_filter(parameter)  #除去数组中的空值和签名模式
		para = {}
		
		parameter.keys.each do |key|
			if !(key == "sign" || key == "sign_type" || parameter[key] == "")
				para[key] = parameter[key]
			end
		end
		return para
	end
	
  # sort key
  def self.arg_sort(array)
    return array
  end
  
	def self.build_mysign(sort_array, key, sign_type = "MD5", keys = [])
	  prestr = self.create_linkstring(sort_array, false, keys)     	#把数组所有元素，按照“参数=参数值”的模式用“&”字符拼接成字符串
    prestr = prestr + key   							      #把拼接后的字符串再与安全校验码直接连接起来
    mysgin = self.sign(prestr, sign_type)    			  #把最终的字符串签名，获得签名结果
    return mysgin
  end
  
  def self.create_linkstring(array, get = false, keys = []) #sort_array
    arg = "";
    if keys == []
      keys = array.keys.sort
    end
      
    keys.each do |key|
      #if get
      #  arg += (key + '=' + URI.escape(array[key]) + '&')
      #else
        arg += (key + '=' + (array[key]) + '&')
      #end
 		end
		arg = arg[0, arg.length - 1]
		return arg
	end		  
  
  # 构建签名
	def self.sign(prestr, sign_type) 
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
  
  def self.post(values)
    url = URI.parse(values[:gateway])
    req = Net::HTTP::Post.new(url.path)
    req.body = values[:req_data]
    res = Net::HTTP.start(url.host, url.port) { |http| http.request(req) }
    data = res.body
    return data
  end
  
  def self.getToken(result, values)
    arr = result.split('&')			        	#根据 & 符号拆分
    temp = {}							                #临时存放拆分的数组
  	my_array = {}           						  #待签名的数组
  	#循环构造key、value数组

  	0.upto arr.count do |i|
  	  temp = []
  	  if arr[i]
    	  index = arr[i].index('=')
    	  length = arr[i].length
    	  temp << arr[i][0,index]
    	  temp << arr[i][index + 1, length - index - 1]
    		my_array[temp[0]] = temp[1]
    		puts temp[1]
  		end
  	end
  	puts 'in get token'
    token = self.getDataForXML(my_array['res_data'],'/direct_trade_create_res/request_token');	#返回token
	  
  	puts token
	  return { :token => token, :values => values }
  end
  
  def self.getDataForXML(res_data, node)
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
  
  def self.alipay_Wap_Auth_AuthAndExecute(parameter, key, values)
    values[:parameter] = self.para_filter(parameter)
		sort_array = self.arg_sort(values[:parameter])
		values[:sign_type] = values[:parameter]['sec_id']
		values[:_key] = key
		values[:mysign] = self.build_mysign(sort_array, values[:_key],values[:sign_type])
    redirect_url = values[:gateway] + create_linkstring(values[:parameter], true) + 
      '&sign=' + URI.escape(values[:mysign])
    return redirect_url
  end    
  
  # ==================================
  
  
  

  def self.return_verify(values, params)
    if (params == nil)
      return false
    else
      get = self.para_filter(params)
      sort_get = self.arg_sort(params)
      values[:mysign] = self.build_mysign(sort_get, values[:_key], values[:sign_type])
      if values[:mysign] == params[:sign]
        return true
      else
        return false
      end
    end
  end
  
  
  def self.notify_verify(values, params)
    if (params = nil)
      return false
    else
      notifyarray = {}
      notifyarray['service'] = params[:service]
      notifyarray['v'] = params[:v]
      notifyarray['sec_id'] = params[:sec_id]
      notifyarray['notify_data'] = params[:notify_data]
      values[:mysign] = self.build_mysign(notifyarray, values[:_key], values[:sign_type], ['service','v','sec_id','notify_data'])
      if (values[:mysign] == params[:sign])
        return true
      else
        return false
      end
    end
  end
  





  # 得到支付链接
  def self.get_page(list)
  
    # 变参
    partner		    = PARTNER	#合作身份者ID，以2088开头的16位纯数字
    key   	  		= KEY	#安全检验码，以数字和字母组成的32位字符
    seller_email	= SELLEREMAIL	#签约支付宝账号或卖家支付宝帐户
    notify_url		= NOTIFYURL	#异步返回消息通知页面，用于告知商户订单状态
    call_back_url	= CALLBACKURL	#同步返回消息通知页面，用于提示商户订单状态
    merchant_url	= "http://"	#网站商品的展示地址
    subject   		= "测试"	#产品名称
    out_trade_no	= list.slip_code#'001100' + DateTime.now.strftime('%Y%m%d%H%M%S')	#请与贵网站订单系统中的唯一订单号匹配
    total_fee 		= list.total_price.to_s#"0.01"	#订单总金额，显示在支付宝收银台里的“应付总额”里
    out_user  		= list.user.id.to_s#user_id#"1111"	#外部商号，买家的唯一标示
  
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
      
    result = self.alipay_wap_trade_create_direct(pms1,key,sec_id)
    token = result[:token]
    
    #puts token.inspect
  
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
  
      result = self.alipay_Wap_Auth_AuthAndExecute(pms2, key, values)
      return result
    else
      return false
    end

  end  


  def self.return_page(params)
    #puts params
  
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
    values[:sign_type] = sec_id
    values[:_input_charset] = _input_charset
    
    verify_result = self.return_verify(values, params)
  
    if verify_result  
      return true
    else
      return false
    end
    
    
  end

  def self.notify_page(params)
    
    #puts params
  
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
    values[:sign_type] = sec_id
    values[:_input_charset] = _input_charset
    
    verify_result = self.notify_verify(values, params)
  
    if verify_result  
      return true
    else
      return false
    end
  end

end