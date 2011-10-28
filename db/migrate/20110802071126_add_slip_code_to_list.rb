class AddSlipCodeToList < ActiveRecord::Migration
  def self.up
    add_column(:shopping_lists, :slip_code, :string)
  end

  def self.down
    remove_column(:shopping_lists, :slip_code)
  end
end
