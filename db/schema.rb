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

ActiveRecord::Schema.define(:version => 20140531013646) do

  create_table "qsos", :force => true do |t|
    t.integer  "time_upper"
    t.integer  "time_lower"
    t.decimal  "transmit_frequency", :precision => 10, :scale => 0
    t.decimal  "receive_frequency",  :precision => 10, :scale => 0
    t.integer  "band"
    t.string   "station"
    t.integer  "mode"
    t.integer  "dupe"
    t.integer  "serial"
    t.integer  "version"
    t.string   "id_key"
    t.string   "updated_by"
    t.string   "operating_class"
    t.string   "section"
    t.string   "c_field"
    t.string   "country_prefix"
    t.datetime "created_at",                                        :null => false
    t.datetime "updated_at",                                        :null => false
  end

end
