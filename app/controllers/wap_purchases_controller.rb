
#require 'json'
require 'lib/alipay'

class WapPurchasesController < ApplicationController
  
  before_filter :require_admin_login, :only => []
  
  # 查询：get    
  # params:  "id"
  def require_info
    product = Product.find_by_id(params[:id])
    respond_to do |format|
      format.json {
        if product
          # name image_url amount unitprice id description
          p_hash = {}
          p_hash[:name] = product.name_info.to_s
          #p_hash[:image_url] = product.image_url_info.to_s
          p_hash[:amount] = product.amount.to_s
          p_hash[:unitprice] = product.unitprice_info.to_s
          p_hash[:id] = product.id.to_s
          p_hash[:description] = product.description_info.to_s
          p_hash[:success] = '1'
          p_hash[:icon] = product.info.image.url(:icon)
          p_hash[:origion] = product.info.image.url
          render( :json => p_hash )
        else
          render( :json => { :success => '0' })
        end
      }
    end
  end
  
  def get_pay_url(list)
    slip_code = '' # 4(customer_id) + 6(order_id) , means "BillNo" 10 bit
    slip_code += '0001'
    code = list.id.to_s
    if code.size < 6
      (6 - code.size).times do |i|
        code = '0' + code
      end
    end
    slip_code += code
    list.slip_code = slip_code
    pay_url = SyAlipay.get_page(list)
    return {:pay_url => pay_url, :slip_code => slip_code}
  end
  
  # 下单：post    params : 
  # {"cellphone"=>"13761022651",'name'=>'myname','address'=>"someplace",shopping_list=>[{"product_id"=>"2",amount=>"1""},{"product_id"=>"3",amount=>"2"},{"product_id"=>"3",amount=>"2"}]}     
  # 返回：｛“slip_code”=>"购物单号","pay_url"=>"支付宝链接地址？","total_price"=>420.0｝
  def post_order
    cellphone = params[:cellphone]
    address = params[:address]
    name = params[:name]
    errno = 0
    err_msg = ''
    status = false
    pay_url = ''
    
    if !cellphone
      errno += 1
      err_msg += "cellphone can't be blank"#'电话号码不得为空。'
    end
    if !address
      errno += 1
      err_msg += "address can't be blank"#'收件地址不得为空。'
    end
    if !name
      errno += 1
      err_msg += "name can't be blank"#'收件人不得为空。'
    end
    
    shopping_list = params[:shopping_list]
    if !shopping_list
      errno += 1
      err_msg += "order can't be blank"#'订单内容不得为空。'
    elsif shopping_list.size == 0
      errno += 1
      err_msg += "order content can't be blank"#'订单内容不得为空。'
    end
    
    items = []
    if errno == 0 # array
      list = ShoppingList.new
      list.cellphone = params[:cellphone]
      list.address = params[:address]
      list.name = params[:name]
      
      shopping_list.each do |shopping_item| # hash
        product = Product.find_by_id(shopping_item[:product_id])
        if product && (product.amount.to_i - product.order_amount.to_i <= 0)
          errno += 1
          err_msg += "product storage of" + product.name.to_s + "is not adequate"#'商品'+product.name.to_s+'库存不足。'
          break
        end
      end
      
      if errno == 0 
        begin
          ActiveRecord::Base.transaction do 
            list.save!
            total_price = 0
            shopping_list.each do |shopping_item| # hash
              item = ShoppingItem.new
              item.shopping_list_id = list.id
              item.product_id = shopping_item[:product_id]
              item.amount = shopping_item[:amount]
              product = item.product
              item.unitprice = product.unitprice_info
              item.save!
              items << item
              total_price += item.unitprice.to_f * item.amount.to_i
              product.order_amount = product.order_amount.to_i + item.amount.to_i
              product.save!
            end
            list.total_price = total_price
            list.save!
          
            user = User.find_by_cellphone(params[:cellphone])
            if !user && params[:cellphone]
              user = User.new
              user.cellphone = params[:cellphone]
              user.save!
            end
          
            result = get_pay_url(list) #get_pay_url

            list.slip_code = result[:slip_code]
            pay_url = result[:pay_url]
          
            if result[:pay_url] && result[:pay_url] != ''
              list.state = ShoppingList.state['wait_for_payment']
              list.pay_moment = DateTime.now
              list.save!
              status = true
            end
          end
        rescue ActiveRecord::RecordInvalid => invalid
          #flash[:error] = invalid.to_s
          status = false
          err_msg += "get error when saving the order"#'订单保存错误。'
        end
      end
    end
    
    respond_to do |format|
      format.json {
        if status
          render( :json => { :success => '1', :total_price => list.total_price.to_s, :list_id => list.id.to_s, :list => list.to_json, :items => items.to_json, :pay_url => pay_url })
        else
          render( :json => { :success => '0', :err_msg => err_msg })
        end
      }
    end
  end
  
  # params [:id]
  def pay_order
    list = params[:id]
    if list
      begin
        ActiveRecord::Base.transaction do 
        
          result = get_pay_url(list) #get_pay_url

          list.slip_code = result[:slip_code]
          pay_url = result[:pay_url]
        
          if result[:pay_url] && result[:pay_url] != ''
            list.state = ShoppingList.state['wait_for_payment']
            list.pay_moment = DateTime.now
            list.save!
            status = true
          end
        end
      rescue ActiveRecord::RecordInvalid => invalid
        #flash[:error] = invalid.to_s
        status = false
        err_msg += "get error when saving the order"#'订单保存错误。'
      end
    end
    
    #'&MerchantUrl=xxxx&MerchantPara=xxxx'
    #'https://netpay.cmbchina.com/netpayment/BaseHttp.dll?MfcISAPICommand=TestPrePayWAP&BranchID=xxxx&CoNo=123456&BillNo=333333&Amount=111.11&Date=20110606&MerchantUrl=xxxx&MerchantPara=xxxx'
    
    respond_to do |format|
      format.json {
        if status
          render( :json => { :success => '1', :total_price => list.total_price, :list_id => list.id, :list => list.to_json, :items => items.to_json, :pay_url => pay_url })
        else
          render( :json => { :success => '0', :err_msg => err_msg })
        end
      }
    end
    
    
    
  end

  def post_order_2
    info = JSON.parse(params)
    cellphone = info[:cellphone]
    address = info[:address]
    name = info[:name]
    errno = 0
    err_msg = ''
    status = false
    pay_url = ''
    
    if !cellphone
      errno += 1
      err_msg += "cellphone can't be blank"#'电话号码不得为空。'
    end
    if !address
      errno += 1
      err_msg += "address can't be blank"#'收件地址不得为空。'
    end
    if !name
      errno += 1
      err_msg += "name can't be blank"#'收件人不得为空。'
    end
    
    shopping_list = info[:shopping_list]
    shopping_list = JSON.parse(shopping_list)
    if !shopping_list
      errno += 1
      err_msg += "order can't be blank"#'订单内容不得为空。'
    elsif shopping_list.size == 0
      errno += 1
      err_msg += "order content can't be blank"#'订单内容不得为空。'
    end
    
    items = []
    if errno == 0 # array
      list = ShoppingList.new
      list.cellphone = info[:cellphone]
      list.address = info[:address]
      list.name = info[:name]
      
      shopping_list.each do |shopping_item| # hash
        product = product.find_by_id(shopping_item[:product_id])
        if product && (product.amount - product.order_amount <= 0)
          errno += 1
          err_msg += "product storage of" + product.name.to_s + "is not adequate"#'商品'+product.name.to_s+'库存不足。'
          break
        end
      end
      
      if errno == 0 
        begin
          ActiveRecord::Base.transaction do 
            list.save!
            total_price = 0
            shopping_list.each do |shopping_item| # hash
              item = ShoppingItem.new
              item.shopping_list_id = list.id
              item.product_id = shopping_item[:product_id]
              item.amount = shopping_item[:amount]
              product = item.product
              item.unitprice = product.unitprice_info
              item.save!
              items << item
              total_price += item.unitprice * item.amount
              product.order_amount = product.order_amount.to_i + item.amount.to_i
              product.save!
            end
            list.total_price = total_price
            list.save!
          
            result = get_pay_url(list.id) #get_pay_url

            list.slip_code = result[:slip_code]
            pay_url = result[:pay_url]
          
            list.save!
            status = true
          end
        rescue ActiveRecord::RecordInvalid => invalid
          #flash[:error] = invalid.to_s
          status = false
          err_msg += "get error when saving the order"#'订单保存错误。'
        end
      end
    end
    if status
      user = User.find_by_cellphone(info[:cellphone])
      if !user && info[:cellphone]
        user = User.new
        user.cellphone = info[:cellphone]
        user.save
      end
    end
    
    #'&MerchantUrl=xxxx&MerchantPara=xxxx'
    #'https://netpay.cmbchina.com/netpayment/BaseHttp.dll?MfcISAPICommand=TestPrePayWAP&BranchID=xxxx&CoNo=123456&BillNo=333333&Amount=111.11&Date=20110606&MerchantUrl=xxxx&MerchantPara=xxxx'
    
    respond_to do |format|
      format.json {
        if status
          render( :json => { :success => '1', :list_id => list.id, :list => list.to_json, :items => items.to_json, :pay_url => pay_url })
        else
          render( :json => { :success => '0', :err_msg => err_msg })
        end
      }
    end
  end

  
  # id
  def cancel_list
    shopping_list = ShoppingList.find_by_id(params[:id])
    status = '0'
    if shopping_list && (shopping_list.state == ShoppingList.state['init'] || shopping_list.state == ShoppingList.state['wait_for_payment'])
      begin
        ActiveRecord::Base.transaction do 
          shopping_list.state = ShoppingList.state['cancel']
          shopping_list.save!
          shopping_list.shopping_items.each do |shopping_item| 
            product.order_amount = product.order_amount - shopping_item.amount
            product.save!
          end
          
          status = '1'
        end
      rescue ActiveRecord::RecordInvalid => invalid
        status = '0'
      end
      
    end
    respond_to do |format|
      format.json {
        render( :json => { :success => status })
      }
    end
  end
  
  # id
  def check_list_state
    status = false
    shopping_list = ShoppingList.find_by_id(params[:id])
    
    if shopping_list && shopping_list.state == ShoppingList.state['wait_for_payment']
      if !shopping_list.pay_moment || (Time.now - shopping_list.pay_moment) > 1000
        shopping_list.state = ShoppingList.state['init']
        shopping_list.save
      end        
    end
    if shopping_list
      status = shopping_list.state.to_s
    else
      status = '-1'
    end
    respond_to do |format|
      format.json {
        render( :json => { :success => status })
      }
    end
  end
end
