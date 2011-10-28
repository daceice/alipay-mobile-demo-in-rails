class CreateShoppingLists < ActiveRecord::Migration
  def self.up
    create_table :shopping_lists do |t|
      t.string :cellphone
      t.string :address
      t.string :name
      t.float :total_price

      t.timestamps
    end
  end

  def self.down
    drop_table :shopping_lists
  end
end
