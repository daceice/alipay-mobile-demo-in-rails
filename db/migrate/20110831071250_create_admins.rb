require 'base64'
class CreateAdmins < ActiveRecord::Migration
  def self.up
    create_table :admins do |t|
      t.string :login_name
      t.string :password
      t.boolean :available, :default => true

      t.timestamps
    end
    if Admin.count == 0
      admin = Admin.new
      admin.login_name = 'manager'
      admin.plain_password = '111111'
      admin.encrypt
      admin.save
    end
  end

  def self.down
    drop_table :admins
  end
end
