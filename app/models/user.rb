class User < ActiveRecord::Base
  has_many :shopping_lists, :class_name => "ShoppingList", :foreign_key => "cellphone", :primary_key => "cellphone"
  validates_presence_of :cellphone
  validates_uniqueness_of :cellphone
end
