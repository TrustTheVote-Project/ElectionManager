# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100408141149) do

  create_table "ballot_style_templates", :force => true do |t|
    t.string   "display_name"
    t.integer  "default_voting_method"
    t.text     "instruction_text"
    t.string   "state_graphic"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "ballot_style"
  end

  create_table "candidates", :force => true do |t|
    t.string   "display_name"
    t.integer  "party_id"
    t.integer  "contest_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "ident"
    t.integer  "order",        :default => 0
  end

  create_table "contests", :force => true do |t|
    t.string   "display_name"
    t.integer  "open_seat_count"
    t.integer  "voting_method_id"
    t.integer  "district_id"
    t.integer  "election_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "order",            :default => 0
  end

  create_table "district_sets", :force => true do |t|
    t.string   "display_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "district_sets_districts", :id => false, :force => true do |t|
    t.integer "district_set_id"
    t.integer "district_id"
  end

  create_table "district_types", :force => true do |t|
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "districts", :force => true do |t|
    t.integer  "district_type_id"
    t.string   "display_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "ident"
  end

  create_table "districts_precincts", :id => false, :force => true do |t|
    t.integer "precinct_id"
    t.integer "district_id"
  end

  create_table "elections", :force => true do |t|
    t.string   "display_name"
    t.integer  "district_set_id"
    t.datetime "start_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "ballot_style_template_id"
  end

  create_table "parties", :force => true do |t|
    t.string   "display_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "ident"
  end

  create_table "precincts", :force => true do |t|
    t.string   "display_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "ident"
  end

  create_table "questions", :force => true do |t|
    t.string   "display_name"
    t.text     "question"
    t.integer  "district_id"
    t.integer  "election_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "crypted_password"
    t.string   "password_salt"
    t.string   "persistence_token"
    t.string   "perishable_token"
    t.integer  "failed_login_count"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["perishable_token"], :name => "index_users_on_perishable_token"

  create_table "voting_methods", :force => true do |t|
    t.string   "display_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
