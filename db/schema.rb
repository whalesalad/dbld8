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

ActiveRecord::Schema.define(:version => 20121110190017) do

  create_table "activities", :force => true do |t|
    t.string   "title",       :null => false
    t.string   "details"
    t.string   "day_pref"
    t.string   "time_pref"
    t.integer  "location_id"
    t.integer  "user_id",     :null => false
    t.integer  "wing_id",     :null => false
    t.string   "status"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "activities", ["status"], :name => "index_activities_on_status"
  add_index "activities", ["user_id"], :name => "index_activities_on_user_id"
  add_index "activities", ["wing_id"], :name => "index_activities_on_wing_id"

  create_table "auth_tokens", :force => true do |t|
    t.integer  "user_id"
    t.string   "token"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "facebook_invites", :force => true do |t|
    t.integer  "user_id"
    t.integer  "facebook_id", :limit => 8
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
  end

  add_index "facebook_invites", ["facebook_id", "user_id"], :name => "index_facebook_invites_on_facebook_id_and_user_id", :unique => true
  add_index "facebook_invites", ["user_id", "facebook_id"], :name => "index_facebook_invites_on_user_id_and_facebook_id", :unique => true

  create_table "friendships", :force => true do |t|
    t.integer  "user_id",                       :null => false
    t.integer  "friend_id",                     :null => false
    t.boolean  "approved",   :default => false
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  add_index "friendships", ["friend_id", "user_id"], :name => "index_friendships_on_friend_id_and_user_id", :unique => true
  add_index "friendships", ["user_id", "friend_id"], :name => "index_friendships_on_user_id_and_friend_id", :unique => true

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
    t.string   "name",                                         :null => false
    t.string   "locality"
    t.string   "state"
    t.string   "country"
    t.float    "latitude"
    t.float    "longitude"
    t.integer  "facebook_id",      :limit => 8
    t.datetime "created_at",                                   :null => false
    t.datetime "updated_at",                                   :null => false
    t.string   "foursquare_id"
    t.string   "venue"
    t.integer  "users_count",                   :default => 0
    t.string   "address"
    t.integer  "geoname_id"
    t.integer  "activities_count",              :default => 0
  end

  add_index "locations", ["facebook_id"], :name => "index_locations_on_facebook_id", :unique => true
  add_index "locations", ["foursquare_id"], :name => "index_locations_on_foursquare_id", :unique => true
  add_index "locations", ["geoname_id"], :name => "index_locations_on_geoname_id", :unique => true
  add_index "locations", ["name"], :name => "index_locations_on_name"

  create_table "user_photos", :force => true do |t|
    t.integer  "user_id"
    t.string   "image"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

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
    t.uuid     "uuid",                                                 :null => false
    t.string   "invite_slug"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["facebook_id"], :name => "index_users_on_facebook_id", :unique => true
  add_index "users", ["invite_slug"], :name => "index_users_on_invite_slug", :unique => true
  add_index "users", ["uuid"], :name => "index_users_on_uuid", :unique => true

end
