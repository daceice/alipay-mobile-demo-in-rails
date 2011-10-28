class CreateInfos < ActiveRecord::Migration
  def self.up
    create_table :infos do |t|
      t.string :name
      t.string :image_url
      t.text :description
      t.float :unitprice
      t.integer :product_id
      t.datetime :start_at
      t.datetime :end_at

      t.timestamps
    end
  end

  def self.down
    drop_table :infos
  end
end
