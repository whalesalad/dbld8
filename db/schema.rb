# encoding: UTF-8
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

ActiveRecord::Schema.define(:version => 20120912043435) do

  create_table "auth_tokens", :force => true do |t|
    t.integer  "user_id"
    t.string   "token"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "interests", :force => true do |t|
    t.string   "name",                     :null => false
    t.integer  "facebook_id", :limit => 8
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
  end

  add_index "interests", ["name"], :name => "index_interests_on_name", :unique => true

  create_table "interests_users", :id => false, :force => true do |t|
    t.integer "user_id"
    t.integer "interest_id"
  end

  add_index "interests_users", ["interest_id", "user_id"], :name => "index_interests_users_on_interest_id_and_user_id"
  add_index "interests_users", ["user_id", "interest_id"], :name => "index_interests_users_on_user_id_and_interest_id"

  create_table "locations", :force => true do |t|
    t.string   "name",                     :null => false
    t.string   "locality"
    t.string   "admin_name"
    t.string   "admin_code"
    t.string   "country"
    t.float    "latitude"
    t.float    "longitude"
    t.integer  "facebook_id", :limit => 8
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
  end

  add_index "locations", ["facebook_id"], :name => "index_locations_on_facebook_id", :unique => true
  add_index "locations", ["name"], :name => "index_locations_on_name", :unique => true

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "password_digest"
    t.integer  "facebook_id",           :limit => 8
    t.string   "facebook_access_token"
    t.string   "first_name"
    t.string   "last_name"
    t.date     "birthday"
    t.boolean  "single",                             :default => true
    t.string   "interested_in"
    t.string   "gender"
    t.text     "bio"
    t.datetime "created_at",                                           :null => false
    t.datetime "updated_at",                                           :null => false
    t.integer  "location_id"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true

end
