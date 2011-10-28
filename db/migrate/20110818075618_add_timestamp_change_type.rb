class AddTimestampChangeType < ActiveRecord::Migration
  def self.up
    change_column(:shopping_lists, :state, :integer)
    change_column_default(:shopping_lists, :state, 0)
    add_column(:shopping_lists, :pay_moment, :datetime)
  end

  def self.down
  end
end
