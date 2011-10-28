class ProductsController < ApplicationController

  # GET /products
  # GET /products.xml
  def index
    @products = Product.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @products }
    end
  end

  # GET /products/1
  # GET /products/1.xml
  def show
    @product = Product.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @product }
    end
  end

  # GET /products/new
  # GET /products/new.xml
  def new
    @product = Product.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @product }
    end
  end

  # GET /products/1/edit
  def edit
    @product = Product.find(params[:id])
    if @product.info
      info = @product.info  
      @product.name = info.name
      @product.description = info.description
      @product.unitprice = info.unitprice
      @product.image
    end
  end

  # POST /products
  # POST /products.xml
  def create
    @product = Product.new(params[:product])
    errno = 0
    err_msg = ''
    if params[:product]
      if !params[:product][:name]
        errno += 1
        err_msg += '商品名称不得为空。'
      elsif !params[:product][:description]
        errno += 1
        err_msg += '商品描述不得为空。'
      #elsif !params[:product][:image_url]
      #  errno += 1
      #  err_msg += '商品图片不得为空。'
      end
    else
      errno += 1
    end
    if !DataVerify.is_positive_integer(@product.amount)
      errno += 1
      err_msg += '库存数量必须为正整数。'
    end
    if !DataVerify.is_positive_float(@product.unitprice)
      errno += 1
      err_msg += '商品价格必须为正数。'
    end
    
    status = false
    begin
      ActiveRecord::Base.transaction do
        @product.save!
        info = Info.new(:image => params[:image])
        info.name = @product.name
        info.image_url = @product.image_url
        info.description = @product.description
        info.unitprice = @product.unitprice
        info.product_id = @product.id
        #info.start_at = DateTime.now
        info.save!
        status = true
      end
    rescue ActiveRecord::RecordInvalid => invalid
      status = false
    end
    respond_to do |format|
      if errno == 0 && status
        format.html { redirect_to(@product, :notice => 'Product was successfully created.') }
        format.xml  { render :xml => @product, :status => :created, :location => @product }
      else
        puts err_msg
        format.html { render :action => "new" }
        format.xml  { render :xml => @product.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /products/1
  # PUT /products/1.xml
  def update
    @product = Product.find(params[:id])
    @product.amount = params[:product][:amount]
    @product.unitprice = params[:product][:unitprice]
    @product.name = params[:product][:name]
    @product.description = params[:product][:description]
    

    errno = 0
    err_msg = ''
    if params[:product]
      if !params[:product][:name]
        errno += 1
        err_msg += '商品名称不得为空。'
      elsif !params[:product][:description]
        errno += 1
        err_msg += '商品描述不得为空。'
      #elsif !params[:product][:image_url]
      #  errno += 1
      #  err_msg += '商品图片不得为空。'
      end
    else
      errno += 1
    end
    if !DataVerify.is_positive_integer(@product.amount)
      errno += 1
      err_msg += '库存数量必须为正整数。'
    end
    if !DataVerify.is_positive_float(@product.unitprice)
      errno += 1
      err_msg += '商品价格必须为正数。'
    end
    
    status = false
    begin
      ActiveRecord::Base.transaction do
        @product.save!
        if !@product.info
          info = Info.new(:image => params[:image])
        else
          info = @product.info
          if params[:image]
            info.update_attributes(:image => params[:image])
          end
        end
        info.name = @product.name
        info.image_url = @product.image_url
        info.description = @product.description
        info.unitprice = @product.unitprice
        info.product_id = @product.id
        #info.start_at = DateTime.now
        info.save!
        status = true
      end
    rescue ActiveRecord::RecordInvalid => invalid
      status = false
    end


    respond_to do |format|
      if status
        format.html { redirect_to(@product, :notice => 'Product was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @product.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /products/1
  # DELETE /products/1.xml
#  def destroy
#    @product = Product.find(params[:id])
#    @product.destroy

#    respond_to do |format|
#      format.html { redirect_to(products_url) }
#      format.xml  { head :ok }
#    end
#  end
  
  def unuse
    @product = Product.find(params[:id])
    @product.available = false
    @product.save

    respond_to do |format|
      format.html { redirect_to(products_url) }
      format.xml  { head :ok }
    end
  end
  
  def reuse
    @product = Product.find(params[:id])
    @product.available = true
    @product.save

    respond_to do |format|
      format.html { redirect_to(products_url) }
      format.xml  { head :ok }
    end
  end
end
