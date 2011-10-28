# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
QrPurchase::Application.initialize!
PARTNER = "2088101000137799" unless defined? PARTNER
KEY = "d33k5kkk3n4nnn3kd33k5kkk3n4nnn3k" unless defined? KEY 
SELLEREMAIL	= "chenf003@yahoo.cn"
NOTIFYURL		= "http://www.example.com/alipay_page/notify_page"	#异步返回消息通知页面，用于告知商户订单状态
CALLBACKURL	= "http://www.example.com/alipay_page/return_page"	#同步返回消息通知页面，用于提示商户订单状态
