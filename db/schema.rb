# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_03_28_192858) do

  create_table "cards", force: :cascade do |t|
    t.integer "game_id"
    t.integer "player_id"
    t.string "suit"
    t.string "rank"
    t.integer "location"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "games", force: :cascade do |t|
    t.string "room_name"
    t.integer "next_to_play"
    t.integer "round"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "pot"
    t.integer "high_bet"
    t.integer "current_player"
    t.integer "high_better"
    t.integer "dealer"
  end

  create_table "players", force: :cascade do |t|
    t.integer "game_id"
    t.integer "user_id"
    t.string "ai"
    t.string "username"
    t.integer "location"
    t.integer "money"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "in_hand"
    t.integer "in_pot_current"
    t.integer "in_pot_hand"
  end

  create_table "users", force: :cascade do |t|
    t.string "username"
    t.string "password"
    t.integer "money"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "password_digest"
  end

end
