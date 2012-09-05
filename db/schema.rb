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

ActiveRecord::Schema.define(:version => 20120904114059) do

  create_table "interests", :force => true do |t|
    t.string   "name",                     :null => false
    t.integer  "facebook_id", :limit => 8
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
  end

  add_index "interests", ["name"], :name => "index_interests_on_name", :unique => true

  create_table "locations", :force => true do |t|
    t.string   "name",                                                     :null => false
    t.decimal  "lat",                      :precision => 15, :scale => 10
    t.decimal  "lng",                      :precision => 15, :scale => 10
    t.integer  "facebook_id", :limit => 8
    t.datetime "created_at",                                               :null => false
    t.datetime "updated_at",                                               :null => false
  end

  add_index "locations", ["facebook_id"], :name => "index_locations_on_facebook_id", :unique => true

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "password"
    t.integer  "facebook_id",   :limit => 8
    t.string   "first_name"
    t.string   "last_name"
    t.date     "birthday"
    t.boolean  "single"
    t.string   "interested_in"
    t.string   "gender"
    t.text     "bio"
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true

end
