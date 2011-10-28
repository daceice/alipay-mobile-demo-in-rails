class ShoppingList < ActiveRecord::Base
  has_many :shopping_items
  belongs_to :user, :class_name => "User", :foreign_key => "cellphone", :primary_key => "cellphone"
  validates_presence_of :cellphone
  validates_presence_of :address
  validates_presence_of :name
  
  def self.state
    return @@state
  end
  
  def self.state_str
    return @@state.invert
  end
  
  @@state = {
    'init' => 0,
    'wait_for_payment' => 1,
    'payed' => 2,
    'sent' => 3,
    'finish' => 4,
    'cancel' => 5
  }
end
