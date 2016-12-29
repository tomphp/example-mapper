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

ActiveRecord::Schema.define(version: 20161229191807) do

  create_table "cards", primary_key: "card_id", force: :cascade do |t|
    t.string "story_id", limit: 100,  default: "", null: false
    t.string "text",     limit: 2000, default: "", null: false
    t.string "state",    limit: 20,   default: "", null: false
  end

  create_table "examples", id: false, force: :cascade do |t|
    t.string   "rule_card_id", limit: 100, default: "", null: false
    t.string   "card_id",      limit: 100, default: "", null: false
    t.datetime "created",                               null: false
  end

  create_table "questions", id: false, force: :cascade do |t|
    t.string   "story_id", limit: 100, default: "", null: false
    t.string   "card_id",  limit: 100, default: "", null: false
    t.datetime "created",                           null: false
  end

  create_table "rules", id: false, force: :cascade do |t|
    t.string  "story_id", limit: 100, default: "", null: false
    t.string  "card_id",  limit: 100, default: "", null: false
    t.integer "position", limit: 4,   default: 0,  null: false
  end

  create_table "stories", id: false, force: :cascade do |t|
    t.string "story_id",   limit: 100, default: "", null: false
    t.string "story_card", limit: 100, default: "", null: false
  end

end
