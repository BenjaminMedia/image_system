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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140327101210) do

  create_table "photo_aspects", force: true do |t|
    t.string   "name"
    t.float    "aspect_ratio"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "photo_crops", force: true do |t|
    t.integer  "y1"
    t.integer  "x1"
    t.integer  "y2"
    t.integer  "x2"
    t.integer  "photo_id"
    t.integer  "photo_aspect_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "photo_crops", ["photo_aspect_id"], name: "index_photo_crops_on_photo_aspect_id"
  add_index "photo_crops", ["photo_id"], name: "index_photo_crops_on_photo_id"

  create_table "photos", force: true do |t|
    t.string   "uuid"
    t.integer  "width"
    t.integer  "height"
    t.string   "file_extension"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "photos", ["uuid"], name: "index_photos_on_uuid", unique: true

end
