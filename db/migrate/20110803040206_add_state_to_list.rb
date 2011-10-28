class AddStateToList < ActiveRecord::Migration
  def self.up
    add_column(:shopping_lists, :state, :string, {:default => 'init'})
  end

  def self.down
    remove_column(:shopping_lists, :state)
  end
end
