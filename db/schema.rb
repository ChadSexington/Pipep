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

ActiveRecord::Schema.define(version: 20141119042646) do

  create_table "datafiles", force: true do |t|
    t.string   "upstream_location"
    t.string   "local_location"
    t.float    "percent_complete",  default: 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "size"
    t.integer  "download_id"
  end

  create_table "delayed_jobs", force: true do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority"

  create_table "downloads", force: true do |t|
    t.integer  "torrent_id"
    t.boolean  "complete",         default: false
    t.boolean  "started",          default: false
    t.string   "location"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "percent_complete", default: 0.0
  end

  create_table "torrents", force: true do |t|
    t.datetime "added_date"
    t.integer  "upstream_id"
    t.boolean  "finished"
    t.string   "name"
    t.float    "percent_complete"
    t.integer  "d_rate"
    t.integer  "u_rate"
    t.integer  "size",             limit: 16
    t.integer  "transmission_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "url"
  end

  create_table "transmissions", force: true do |t|
    t.string   "name"
    t.string   "url"
    t.string   "username"
    t.text     "password"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.string   "sftp_username"
    t.string   "sftp_password"
    t.string   "sftp_host"
    t.string   "sftp_dir"
  end

  create_table "users", force: true do |t|
    t.string   "username"
    t.string   "salt"
    t.string   "hashed_password"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
