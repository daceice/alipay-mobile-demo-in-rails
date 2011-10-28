class AddAvaAndOrderToList < ActiveRecord::Migration
  def self.up
    add_column(:products, :available, :boolean)
    add_column(:products, :order_amount, :integer)
  end

  def self.down
    remove_column(:products, :available)
    remove_column(:products, :order_amount)
  end
end
