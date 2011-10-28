class CreateProducts < ActiveRecord::Migration
  def self.up
    create_table :products do |t|
      t.string :image_url
      t.string :name
      t.text :description
      t.float :unitprice
      t.integer :amount

      t.timestamps
    end
  end

  def self.down
    drop_table :products
  end
end
