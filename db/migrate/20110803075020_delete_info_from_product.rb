class DeleteInfoFromProduct < ActiveRecord::Migration
  def self.up
    remove_column(:products, :name)
    remove_column(:products, :image_url)
    remove_column(:products, :description)
    remove_column(:products, :unitprice)
  end

  def self.down
    add_column(:products, :name, :string)
    add_column(:products, :image_url, :string)
    add_column(:products, :description, :text)
    add_column(:products, :unitprice, :float)
  end
end
