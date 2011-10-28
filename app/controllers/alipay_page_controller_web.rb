class AlipayPageController < ApplicationController
  
  #layout 'user'
    
  #before_filter :redirect_if_not_user
  
  #@@gateway = "https://www.alipay.com/cooperate/gateway.do?"        #支付接口
	#@@parameter = ""
	#@@security_code = ""
	#@@mysign  = ""         #签名
	
	#@@partner = ""    #合作伙伴ID
	#@@sign_type = ""       #加密方式 系统默认
	#@@_input_charset = ""    #字符编码格式
	#@@transport = ""        #访问模式
	
	
	def index
	  
  end
  
  # 得到支付链接
  def get_page  
    partner        = PARTNER         #合作伙伴ID #sofapop网上商城
    security_code  = KEY       #安全检验码
    seller_email   = SELLEREMAIL       #卖家支付宝帐户
    _input_charset  = "utf-8"  #字符编码格式  目前支持 GBK 或 utf-8
    sign_type      = "MD5"    #加密方式  系统默认(不要修改)
    transport      = "https"  #访问模式,你可以根据自己的服务器是否支持ssl访问而选择http以及https访问模式(系统默认,不要修改)
    notify_url     = NOTIFYURL #交易过程中服务器通知的页面 要用 http://格式的完整路径
    return_url     = CALLBACKURL #付完款后跳转的页面 要用 http://格式的完整路径
    show_url       = "http://www.veryrender.com"        #你网站商品的展示地址       
    out_trade_no   =  '001100' + DateTime.now.strftime('%Y%m%d%H%M%S')
    parameter = {
      "service"         => "create_direct_pay_by_user",  #交易类型
  	  "partner"         => partner,          #合作商户号
  	  "return_url"      => return_url,       #同步返回
  	  "notify_url"      => notify_url,       #异步返回
  	  "_input_charset"  => _input_charset,    #字符集，默认为GBK
  	  "subject"         => "二维码扫描购物测试",        #商品名称，必填
  	  "body"            => "用户id：" + session[:user_id].to_s + "，交易流水号：" + out_trade_no, #+"用户名："+@current_user.name,        #商品描述，必填
  	  "out_trade_no"    => out_trade_no,        #商品外部交易号，必填（保证唯一性）
  	  "payment_type"    => "1",                 #默认为1,不需要修改
  	  "total_fee"       => '0.01',                #商品单价，必填（价格不能为0）
  	  "show_url"        => show_url,         #商品相关网站
  	  "seller_email"    => seller_email      #卖家邮箱，必填
    }
    result = alipay_service( parameter, security_code, sign_type, "https")
    link = create_url(result)
    redirect_to link
  end  
  
  
  
  
  
  
  
  
  
  def notify_page #异步
  end 
  
  
  def return_page #成功后跳转
    @partner        = "2088201874839866"       #合作伙伴ID
    @security_code  = "czzzp3xbj50dhkpf0iqwub77tzfw2ob6"       #安全检验码
    @seller_email   = "yufeng@aio.sh.cn"       #卖家支付宝帐户
    @_input_charset = "utf-8"  #字符编码格式  目前支持 GBK 或 utf-8
    @sign_type      = "MD5"    #加密方式  系统默认(不要修改)
    @transport      = "https"  #访问模式,你可以根据自己的服务器是否支持ssl访问而选择http以及https访问模式(系统默认,不要修改)
    @notify_url     = "http://localhost:3000/notify_url/notify_url" #交易过程中服务器通知的页面 要用 http://格式的完整路径
    @return_url     = "http://localhost:3000/return_url/return_url" #付完款后跳转的页面 要用 http://格式的完整路径
    @show_url       = "http://www.veryrender.com"        #你网站商品的展示地址  

    alipay_notify(params,@partner,@security_code,@sign_type,@_input_charset,@transport)
    verify_result = true
    flash[:error]=return_verify()
    coin_flow=CoinFlow.find(:first,:conditions=>["out_trade_no==?",params[:out_trade_no]])

    if verify_result && params[:is_success]=="T" && params[:total_fee].to_i==coin_flow.quantity && params[:trade_status]=="TRADE_FINISHED" && coin_flow.state=="before_payed"
      coin_flow.state="payed_and_wait"
      coin_flow.save
      
      log_log("user",session[:user_id],"购买渲币，支付成功，流水号为"+params[:out_trade_no])
      flash[:notice]="充值成功，将在24小时内进入你的帐户。<br>本次交易流水号：#{params[:out_trade_no]}"
    else   
      flash[:error]="充值失败，请联系客服人员询问。<br>本次交易流水号：#{params[:out_trade_no]}"
    end
  end
  

  protected
  
  # 处理参数
	def alipay_service(parameter,security_code,sign_type,transport) 
	  result = {}
		result[:parameter]        = para_filter(parameter)
		result[:security_code]    = security_code
		result[:sign_type]        = sign_type
		result[:mysign]           = ''
		result[:transport]        = transport
		if(parameter['_input_charset'] == "")
		  result[:parameter]['_input_charset'] = 'GBK'
	  end
		if(result[:transport] == "https") 
		  result[:gateway] = "https://www.alipay.com/cooperate/gateway.do?"
		else 
		  result[:gateway] = "http://www.alipay.com/cooperate/gateway.do?"
	  end
		sort_array = {}
		arg = ""
		sort_array = result[:parameter]
		puts sort_array.inspect
		sort_array.keys.sort.each do |key|		  
  		if (key != "sign" && key != "sign_type" )
		    arg += key + "=" + sort_array[key] + "&"
	    end
	  end
	  prestr = arg[0, arg.length - 1]
	  result[:mysign] = sign( prestr + result[:security_code], result[:sign_type])
	  return result
	end	
	
	
  # 构建签名
	def sign(prestr, sign_type) 
		mysign = ""
		if(sign_type == 'MD5') 
			mysign = Digest::MD5.hexdigest(prestr)
		elsif (sign_type == 'DSA') 
			#DSA 签名方法待后续开发
			exit("DSA 签名方法待后续开发，请先使用MD5签名方式")
		else 
			exit("支付宝暂不支持" + sign_type + "类型的签名方式")
		end
		return mysign
	end
  
	
		
	# 构建支付链接	
	def create_url( inputs ) 
		url        = inputs[:gateway]
		sort_array = {}
		arg        = ""
		sort_array = inputs[:parameter]
		sort_array.keys.sort.each do |key|
		  arg += key + "=" + URI.escape(sort_array[key]) + "&"
	  end
	  url += arg + "sign=" + inputs[:mysign] + "&sign_type=" + inputs[:sign_type]
	  return url
  end
  
	
	
	
	
	
	
	
	
 	def alipay_notify(parameter,partner,security_code,sign_type,_input_charset,transport) 
    @@parameter      = parameter
 		@@partner        = partner
 		@@security_code  = security_code
 		@@sign_type      = sign_type
 		@@mysign         = ""
 		@@_input_charset = _input_charset 
 		@@transport      = transport
 		if(@@transport == "https") 
 			@@gateway = "https://www.alipay.com/cooperate/gateway.do?"
 		else 
 		  @@gateway = "http://notify.alipay.com/trade/notify_query.do?"
	  end
  end
	  

     
  ##################对return_url的认证####################
	def return_verify() 
	  sort_get={}
		sort_get= @@parameter
		arg=""
		sort_get.keys.sort.each do |key|
			if (key != "sign" && key != "sign_type" && key !="action" && key != "controller")
				arg+=key+"="+ sort_get[key]+"&"
			end
		end
		prestr = arg[0,arg.length-1]  #去掉最后一个&号
		@@mysign = sign(prestr+@@security_code)
		if (@@mysign == sort_get["sign"])  
		  return true
		else 
		  return false
	  end
	  
	  #return sort_get.keys.join(",")#@@mysign#+"/"+sort_get["sign"]
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

	
	

  
  
  
=begin  
  
  
  #################对notify_url的认证#################
	def notify_verify()
		if(@@transport == "https")
			veryfy_url = @@gateway+"service=notify_verify"+"&partner="+@@partner+"&notify_id="+params["notify_id"]
		else
			veryfy_url = @@gateway+"partner="+@@partner+"&notify_id="+params["notify_id"]
		end
		veryfy_result  = get_verify(veryfy_url)
		post           = para_filter(params)
		sort_post      = post
		arg = ""
		sort_post.keys.sort.each do |key|
		  arg+=key+"="+sort_post[key]+"&"
	  end
  	prestr = arg[0,arg.length-1]
	  @@mysign = sign(prestr+@@security_code)
		if  @@mysign == params["sign"] # && with_true("true$",veryfy_result) 
			return true
		else
		  return false
	  end
	end
  	
	def with_true(sub,obj)  
    check=(obj=~/#{sub}/)
    if check==nil || obj.to_i==0
      return false
    else
      return true
    end
  end
  
  
  
	def get_verify(url, time_out = "60") 
	 	urlarr     = parse_url(url)
		errno      = ""
		errstr     = ""
		transports = ""
		if(urlarr["scheme"] == "https") 
			transports = "ssl://"
			urlarr["port"] = "443"
		else
			transports = "tcp://"
			urlarr["port"] = "80"
		end
    arg=""
		params.keys.each do |key|
		  arg+=key+"="+params[key]+"&"
		end
		return info
	end
=end  
  
end
