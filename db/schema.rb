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

ActiveRecord::Schema.define(version: 20140107052156) do

  create_table "acceptance_votes", force: true do |t|
    t.integer  "nomination_id", null: false
    t.integer  "player_id",     null: false
    t.boolean  "is_accept"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "acceptance_votes", ["nomination_id"], name: "index_acceptance_votes_on_nomination_id"
  add_index "acceptance_votes", ["player_id"], name: "index_acceptance_votes_on_player_id"

  create_table "game_invitees", force: true do |t|
    t.integer  "game_id",                    null: false
    t.integer  "user_id",                    null: false
    t.boolean  "is_joined",  default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "game_invitees", ["game_id"], name: "index_game_invitees_on_game_id"
  add_index "game_invitees", ["user_id"], name: "index_game_invitees_on_user_id"

  create_table "game_options", force: true do |t|
    t.integer  "game_id",             null: false
    t.integer  "enabled_option_type", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "game_options", ["game_id"], name: "index_game_options_on_game_id"

  create_table "game_rounds", force: true do |t|
    t.integer  "game_id",                                 null: false
    t.integer  "round_number",                            null: false
    t.boolean  "is_mission_success"
    t.boolean  "is_complete",             default: false, null: false
    t.integer  "nomination_count",                        null: false
    t.integer  "count_required_for_fail",                 null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "game_rounds", ["game_id"], name: "index_game_rounds_on_game_id"

  create_table "games", force: true do |t|
    t.integer  "status",       null: false
    t.string   "title",        null: false
    t.integer  "player_count", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "mission_votes", force: true do |t|
    t.integer  "round_id",   null: false
    t.integer  "player_id",  null: false
    t.boolean  "is_pass",    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "mission_votes", ["player_id"], name: "index_mission_votes_on_player_id"
  add_index "mission_votes", ["round_id"], name: "index_mission_votes_on_round_id"

  create_table "nominees", force: true do |t|
    t.integer  "nomination_id", null: false
    t.integer  "player_id",     null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "nominees", ["nomination_id"], name: "index_nominees_on_nomination_id"
  add_index "nominees", ["player_id"], name: "index_nominees_on_player_id"

  create_table "players", force: true do |t|
    t.integer  "user_id",    null: false
    t.integer  "game_id",    null: false
    t.integer  "role_id",    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "players", ["game_id"], name: "index_players_on_game_id"
  add_index "players", ["user_id"], name: "index_players_on_user_id"

  create_table "round_nominations", force: true do |t|
    t.integer  "round_id",                             null: false
    t.integer  "phase",                                null: false
    t.integer  "nominating_player_id",                 null: false
    t.boolean  "is_accepted",          default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "round_nominations", ["nominating_player_id"], name: "index_round_nominations_on_nominating_player_id"
  add_index "round_nominations", ["round_id"], name: "index_round_nominations_on_round_id"

  create_table "user_sessions", force: true do |t|
    t.string   "session_id", null: false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_sessions", ["session_id"], name: "index_user_sessions_on_session_id"
  add_index "user_sessions", ["updated_at"], name: "index_user_sessions_on_updated_at"

  create_table "users", force: true do |t|
    t.string   "name",                default: "", null: false
    t.string   "login",                            null: false
    t.string   "crypted_password",                 null: false
    t.string   "password_salt",                    null: false
    t.string   "email",                            null: false
    t.string   "persistence_token",                null: false
    t.string   "single_access_token",              null: false
    t.string   "perishable_token",                 null: false
    t.integer  "login_count",         default: 0,  null: false
    t.integer  "failed_login_count",  default: 0,  null: false
    t.datetime "last_request_at"
    t.datetime "current_login_at"
    t.datetime "last_login_at"
    t.string   "current_login_ip"
    t.string   "last_login_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
