class CreateShoppingItems < ActiveRecord::Migration
  def self.up
    create_table :shopping_items do |t|
      t.integer :shopping_list_id
      t.integer :product_id
      t.integer :amount
      t.float :unitprice

      t.timestamps
    end
  end

  def self.down
    drop_table :shopping_items
  end
end
