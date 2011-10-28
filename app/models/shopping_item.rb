class ShoppingItem < ActiveRecord::Base
  belongs_to :shopping_list
  belongs_to :product
  validates_presence_of :product_id
  validates_presence_of :shopping_list_id
  validates_presence_of :amount
  validates_presence_of :unitprice
end
