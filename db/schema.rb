# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110831071250) do

  create_table "admins", :force => true do |t|
    t.string   "login_name"
    t.string   "password"
    t.boolean  "available",  :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "infos", :force => true do |t|
    t.string   "name"
    t.string   "image_url"
    t.text     "description"
    t.float    "unitprice"
    t.integer  "product_id"
    t.datetime "start_at"
    t.datetime "end_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
  end

  create_table "products", :force => true do |t|
    t.integer  "amount"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "available"
    t.integer  "order_amount"
  end

  create_table "shopping_items", :force => true do |t|
    t.integer  "shopping_list_id"
    t.integer  "product_id"
    t.integer  "amount"
    t.float    "unitprice"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "shopping_lists", :force => true do |t|
    t.string   "cellphone"
    t.string   "address"
    t.string   "name"
    t.float    "total_price"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "slip_code"
    t.integer  "state",       :limit => 255, :default => 0
    t.datetime "pay_moment"
  end

  create_table "users", :force => true do |t|
    t.string   "cellphone"
    t.string   "password"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end