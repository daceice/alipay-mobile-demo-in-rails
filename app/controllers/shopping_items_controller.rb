class ShoppingItemsController < ApplicationController
  # GET /shopping_items
  # GET /shopping_items.xml
  def index
    @shopping_items = ShoppingItem.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @shopping_items }
    end
  end

  # GET /shopping_items/1
  # GET /shopping_items/1.xml
  def show
    @shopping_item = ShoppingItem.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @shopping_item }
    end
  end

  # GET /shopping_items/new
  # GET /shopping_items/new.xml
  def new
    @shopping_item = ShoppingItem.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @shopping_item }
    end
  end

  # GET /shopping_items/1/edit
  def edit
    @shopping_item = ShoppingItem.find(params[:id])
  end

  # POST /shopping_items
  # POST /shopping_items.xml
  def create
    @shopping_item = ShoppingItem.new(params[:shopping_item])

    respond_to do |format|
      if @shopping_item.save
        format.html { redirect_to(@shopping_item, :notice => 'Shopping item was successfully created.') }
        format.xml  { render :xml => @shopping_item, :status => :created, :location => @shopping_item }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @shopping_item.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /shopping_items/1
  # PUT /shopping_items/1.xml
  def update
    @shopping_item = ShoppingItem.find(params[:id])

    respond_to do |format|
      if @shopping_item.update_attributes(params[:shopping_item])
        format.html { redirect_to(@shopping_item, :notice => 'Shopping item was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @shopping_item.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /shopping_items/1
  # DELETE /shopping_items/1.xml
  def destroy
    @shopping_item = ShoppingItem.find(params[:id])
    @shopping_item.destroy

    respond_to do |format|
      format.html { redirect_to(shopping_items_url) }
      format.xml  { head :ok }
    end
  end
end
