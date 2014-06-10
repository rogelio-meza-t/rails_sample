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

ActiveRecord::Schema.define(:version => 20140609160350) do

  create_table "admins", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  add_index "admins", ["email"], :name => "index_admins_on_email", :unique => true
  add_index "admins", ["reset_password_token"], :name => "index_admins_on_reset_password_token", :unique => true

  create_table "agreement_bindings", :force => true do |t|
    t.integer  "sales_channel_agreement_id"
    t.integer  "tour_operator_id"
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
  end

  create_table "currencies", :force => true do |t|
    t.string   "name"
    t.string   "code"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "separator"
    t.string   "delimiter"
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "price_description_translations", :force => true do |t|
    t.integer  "price_description_id", :null => false
    t.string   "locale",               :null => false
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
    t.string   "description"
    t.string   "name"
  end

  add_index "price_description_translations", ["locale"], :name => "index_price_description_translations_on_locale"
  add_index "price_description_translations", ["price_description_id"], :name => "index_price_description_translations_on_price_description_id"

  create_table "price_descriptions", :force => true do |t|
    t.integer  "product_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "minimum"
  end

  create_table "product_categories", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "product_categories_products", :id => false, :force => true do |t|
    t.integer "product_id"
    t.integer "product_category_id"
  end

  create_table "product_images", :force => true do |t|
    t.integer  "product_id"
    t.string   "url"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
  end

  add_index "product_images", ["product_id"], :name => "index_product_images_on_product_id"

  create_table "product_prices", :force => true do |t|
    t.integer  "product_id"
    t.integer  "price"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
    t.integer  "currency_id"
    t.integer  "price_description_id"
    t.string   "currency_code"
  end

  add_index "product_prices", ["product_id"], :name => "index_product_prices_on_product_id"

  create_table "product_schedules", :force => true do |t|
    t.date     "start_date"
    t.date     "end_date"
    t.string   "days"
    t.integer  "product_id"
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
    t.boolean  "active",     :default => true
    t.time     "start_time"
  end

  create_table "product_translations", :force => true do |t|
    t.integer  "product_id",                       :null => false
    t.string   "locale",                           :null => false
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
    t.string   "name",              :limit => 60
    t.text     "description"
    t.string   "difficulty"
    t.string   "meeting_point"
    t.text     "what_to_bring"
    t.text     "whats_included"
    t.string   "short_description", :limit => 140
  end

  add_index "product_translations", ["locale"], :name => "index_product_translations_on_locale"
  add_index "product_translations", ["product_id"], :name => "index_product_translations_on_product_id"

  create_table "products", :force => true do |t|
    t.integer  "min_capacity",                                              :default => 0
    t.integer  "max_capacity",                                              :default => 0
    t.string   "languages"
    t.integer  "tour_operator_id"
    t.datetime "created_at",                                                                   :null => false
    t.datetime "updated_at",                                                                   :null => false
    t.string   "location"
    t.decimal  "duration",                    :precision => 3, :scale => 1, :default => 0.0
    t.string   "status",                                                    :default => "new"
    t.boolean  "exempt_from_schedule_policy",                               :default => false
    t.integer  "min_api_reservation_hours",                                 :default => 1
    t.integer  "priority",                                                  :default => 1
  end

  add_index "products", ["tour_operator_id"], :name => "index_products_on_tour_operator_id"

  create_table "request_logs", :force => true do |t|
    t.string   "url"
    t.string   "key"
    t.string   "value"
    t.integer  "sales_channel_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "reservations", :force => true do |t|
    t.datetime "created_at",                                         :null => false
    t.datetime "updated_at",                                         :null => false
    t.string   "contact_name"
    t.string   "email"
    t.string   "phone"
    t.integer  "number_of_people"
    t.integer  "scheduled_tour_id"
    t.text     "comments"
    t.boolean  "cancelled",                       :default => false
    t.integer  "sales_channel_id"
    t.string   "place_of_stay"
    t.string   "guid",              :limit => 40
    t.string   "paykey"
    t.boolean  "paid",                            :default => true
  end

  create_table "sales_channel_agreements", :force => true do |t|
    t.integer  "sales_channel_id"
    t.string   "text"
    t.integer  "commission_percent"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  add_index "sales_channel_agreements", ["sales_channel_id"], :name => "index_sales_channel_agreements_on_sales_channel_id"

  create_table "sales_channels", :force => true do |t|
    t.string   "name"
    t.string   "contact_name"
    t.string   "contact_email"
    t.string   "authentication_token"
    t.datetime "created_at",                                            :null => false
    t.datetime "updated_at",                                            :null => false
    t.integer  "sign_in_count",                      :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "guid",                 :limit => 40
    t.boolean  "agreement_exempt",                   :default => false
  end

  create_table "scheduled_tours", :force => true do |t|
    t.integer  "product_id"
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
    t.date     "date"
    t.boolean  "cancelled",              :default => false
    t.boolean  "on_the_fly",             :default => false
    t.integer  "product_schedule_id"
    t.datetime "latest_api_reservation"
    t.text     "comments"
    t.integer  "reserved_count"
  end

  add_index "scheduled_tours", ["product_id"], :name => "index_scheduled_tours_on_product_id"

  create_table "tour_operator_translations", :force => true do |t|
    t.integer  "tour_operator_id",     :null => false
    t.string   "locale",               :null => false
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
    t.text     "description"
    t.text     "terms_and_conditions"
  end

  add_index "tour_operator_translations", ["locale"], :name => "index_tour_operator_translations_on_locale"
  add_index "tour_operator_translations", ["tour_operator_id"], :name => "index_tour_operator_translations_on_tour_operator_id"

  create_table "tour_operators", :force => true do |t|
    t.string   "name"
    t.string   "address"
    t.string   "phone"
    t.string   "contact_person"
    t.datetime "created_at",                                                                     :null => false
    t.datetime "updated_at",                                                                     :null => false
    t.string   "email",                                                       :default => "",    :null => false
    t.string   "encrypted_password",                                          :default => "",    :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                                               :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "logo"
    t.string   "scheduled_tour_availability_policy"
    t.string   "scheduled_tour_availability_policy_parameters"
    t.boolean  "send_daily_email",                                            :default => false
    t.string   "guid",                                          :limit => 40
    t.string   "paypal_email"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.string   "status",                                                      :default => "new"
    t.string   "country"
    t.string   "preferred_language"
    t.string   "time_zone",                                                   :default => "UTC"
  end

  add_index "tour_operators", ["email"], :name => "index_tour_operators_on_email", :unique => true
  add_index "tour_operators", ["reset_password_token"], :name => "index_tour_operators_on_reset_password_token", :unique => true

end
