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

ActiveRecord::Schema.define(:version => 20130319095207) do

  add_extension "hstore"
  add_extension "uuid-ossp"

  create_table "activities", :force => true do |t|
    t.string   "title",       :null => false
    t.string   "details"
    t.string   "day_pref"
    t.string   "time_pref"
    t.integer  "location_id"
    t.integer  "user_id",     :null => false
    t.integer  "wing_id",     :null => false
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "activities", ["location_id"], :name => "index_activities_on_location_id"
  add_index "activities", ["user_id"], :name => "index_activities_on_user_id"
  add_index "activities", ["wing_id"], :name => "index_activities_on_wing_id"

  create_table "auth_tokens", :force => true do |t|
    t.integer  "user_id"
    t.string   "token"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "auth_tokens", ["user_id"], :name => "index_auth_tokens_on_user_id"

  create_table "coin_packages", :force => true do |t|
    t.string   "identifier"
    t.integer  "coins"
    t.boolean  "popular",         :default => false
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
    t.integer  "purchases_count", :default => 0
  end

  add_index "coin_packages", ["identifier"], :name => "index_coin_packages_on_identifier", :unique => true

  create_table "credit_actions", :force => true do |t|
    t.string   "slug"
    t.integer  "cost"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "credit_actions", ["slug"], :name => "index_credit_actions_on_slug", :unique => true

  create_table "devices", :force => true do |t|
    t.integer  "user_id",    :null => false
    t.string   "token",      :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "devices", ["token"], :name => "index_devices_on_token", :unique => true
  add_index "devices", ["user_id"], :name => "index_devices_on_user_id"

  create_table "engagements", :force => true do |t|
    t.integer  "user_id",                        :null => false
    t.integer  "wing_id",                        :null => false
    t.integer  "activity_id",                    :null => false
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
    t.boolean  "ignored",     :default => false
    t.boolean  "unlocked",    :default => false
    t.datetime "unlocked_at"
  end

  add_index "engagements", ["activity_id"], :name => "index_engagements_on_activity_id"
  add_index "engagements", ["ignored"], :name => "index_engagements_on_ignored"
  add_index "engagements", ["user_id", "activity_id"], :name => "index_engagements_on_user_id_and_activity_id", :unique => true
  add_index "engagements", ["user_id"], :name => "index_engagements_on_user_id"
  add_index "engagements", ["wing_id", "activity_id"], :name => "index_engagements_on_wing_id_and_activity_id", :unique => true
  add_index "engagements", ["wing_id"], :name => "index_engagements_on_wing_id"

  create_table "events", :force => true do |t|
    t.integer  "user_id"
    t.string   "type"
    t.integer  "coins"
    t.integer  "related_id"
    t.string   "related_type"
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
    t.integer  "karma",        :default => 0
  end

  add_index "events", ["related_id", "related_type"], :name => "index_user_actions_on_related_id_and_related_type"
  add_index "events", ["user_id"], :name => "index_user_actions_on_user_id"

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
    t.string   "foursquare_icon"
    t.integer  "population",       :limit => 8
  end

  add_index "locations", ["facebook_id"], :name => "index_locations_on_facebook_id", :unique => true
  add_index "locations", ["foursquare_id"], :name => "index_locations_on_foursquare_id", :unique => true
  add_index "locations", ["geoname_id"], :name => "index_locations_on_geoname_id", :unique => true
  add_index "locations", ["name"], :name => "index_locations_on_name"

  create_table "message_proxies", :force => true do |t|
    t.integer  "user_id"
    t.integer  "message_id"
    t.boolean  "unread",     :default => true
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
  end

  add_index "message_proxies", ["message_id"], :name => "index_message_proxies_on_message_id"
  add_index "message_proxies", ["unread"], :name => "index_message_proxies_on_unread"
  add_index "message_proxies", ["user_id", "message_id"], :name => "index_message_proxies_on_user_id_and_message_id", :unique => true
  add_index "message_proxies", ["user_id"], :name => "index_message_proxies_on_user_id"

  create_table "messages", :force => true do |t|
    t.integer  "user_id"
    t.integer  "engagement_id"
    t.text     "message"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "messages", ["engagement_id"], :name => "index_messages_on_engagement_id"
  add_index "messages", ["user_id"], :name => "index_messages_on_user_id"

  create_table "notifications", :force => true do |t|
    t.uuid     "uuid",                             :null => false
    t.integer  "user_id",                          :null => false
    t.boolean  "unread",      :default => true
    t.boolean  "push",        :default => false
    t.boolean  "pushed",      :default => false
    t.string   "callback"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
    t.integer  "target_id"
    t.string   "target_type", :default => "Event"
    t.boolean  "feed_item",   :default => true
  end

  create_table "purchases", :force => true do |t|
    t.integer  "user_id",    :null => false
    t.string   "identifier", :null => false
    t.text     "receipt",    :null => false
    t.boolean  "verified"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "purchases", ["identifier"], :name => "index_purchases_on_coin_package_identifier"
  add_index "purchases", ["user_id"], :name => "index_purchases_on_user_id"
  add_index "purchases", ["verified"], :name => "index_purchases_on_verified"

  create_table "user_photos", :force => true do |t|
    t.integer  "user_id"
    t.string   "image"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "user_photos", ["user_id"], :name => "index_user_photos_on_user_id"

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
    t.string   "type"
    t.hstore   "features"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["facebook_id"], :name => "index_users_on_facebook_id", :unique => true
  add_index "users", ["features"], :name => "index_users_on_features", :index_type => :gist
  add_index "users", ["invite_slug"], :name => "index_users_on_invite_slug", :unique => true
  add_index "users", ["location_id"], :name => "index_users_on_location_id"
  add_index "users", ["uuid"], :name => "index_users_on_uuid", :unique => true

end
