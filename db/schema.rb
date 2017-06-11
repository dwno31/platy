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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170611054911) do

  create_table "feedbacks", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.integer  "user_id"
    t.string   "location"
    t.string   "status"
    t.string   "request_type"
    t.text     "message",      limit: 65535
    t.index ["user_id"], name: "index_feedbacks_on_user_id", using: :btree
  end

  create_table "identities", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "user_id"
    t.string   "provider"
    t.string   "uid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_identities_on_user_id", using: :btree
  end

  create_table "merchants", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.string   "title"
    t.text     "url",        limit: 65535
    t.text     "thumbnail",  limit: 65535
    t.text     "story",      limit: 65535
    t.text     "hashtag",    limit: 65535
    t.string   "category"
    t.text     "explain",    limit: 65535
    t.integer  "rating"
    t.integer  "ranknumber"
  end

  create_table "products", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "merchant_id"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.string   "title"
    t.integer  "price"
    t.text     "hashtag",     limit: 65535
    t.string   "category"
    t.string   "status"
    t.text     "url",         limit: 65535
    t.text     "img_url",     limit: 65535
    t.integer  "rating"
    t.string   "color"
    t.index ["merchant_id"], name: "index_products_on_merchant_id", using: :btree
  end

  create_table "productswithpromotions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "product_id"
    t.integer  "promotion_id"
    t.string   "tag_type"
    t.integer  "discount"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.index ["product_id"], name: "index_productswithpromotions_on_product_id", using: :btree
    t.index ["promotion_id"], name: "index_productswithpromotions_on_promotion_id", using: :btree
  end

  create_table "promotions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "title"
    t.string   "position"
    t.text     "banner_url",        limit: 65535
    t.text     "header_url",        limit: 65535
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.string   "background"
    t.string   "banner_background"
  end

  create_table "sessions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "session_id",               null: false
    t.text     "data",       limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["session_id"], name: "index_sessions_on_session_id", unique: true, using: :btree
    t.index ["updated_at"], name: "index_sessions_on_updated_at", using: :btree
  end

  create_table "userimages", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "user_id"
    t.text     "hashtag",    limit: 65535
    t.string   "category"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.string   "platy"
    t.index ["user_id"], name: "index_userimages_on_user_id", using: :btree
  end

  create_table "userlikeitems", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "user_id"
    t.integer  "product_id"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.boolean  "active",     default: false
    t.index ["product_id"], name: "index_userlikeitems_on_product_id", using: :btree
    t.index ["user_id"], name: "index_userlikeitems_on_user_id", using: :btree
  end

  create_table "userlikeshops", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "user_id"
    t.integer  "merchant_id"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.boolean  "active",      default: false
    t.index ["merchant_id"], name: "index_userlikeshops_on_merchant_id", using: :btree
    t.index ["user_id"], name: "index_userlikeshops_on_user_id", using: :btree
  end

  create_table "users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "prefer"
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  end

  add_foreign_key "identities", "users"
  add_foreign_key "products", "merchants"
  add_foreign_key "productswithpromotions", "products"
  add_foreign_key "productswithpromotions", "promotions"
  add_foreign_key "userlikeitems", "products"
  add_foreign_key "userlikeitems", "users"
  add_foreign_key "userlikeshops", "merchants"
  add_foreign_key "userlikeshops", "users"
end
