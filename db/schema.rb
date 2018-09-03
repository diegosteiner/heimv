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

ActiveRecord::Schema.define(version: 2018_08_14_142754) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "booking_agents", force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.string "email"
    t.text "address"
    t.decimal "provision"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_booking_agents_on_code"
  end

  create_table "booking_transitions", force: :cascade do |t|
    t.string "to_state", null: false
    t.integer "sort_key", null: false
    t.uuid "booking_id", null: false
    t.boolean "most_recent", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.json "metadata", default: {}
    t.json "booking_data", default: {}
    t.index ["booking_id", "most_recent"], name: "index_booking_transitions_parent_most_recent", unique: true, where: "most_recent"
    t.index ["booking_id", "sort_key"], name: "index_booking_transitions_parent_sort", unique: true
    t.index ["booking_id"], name: "index_booking_transitions_on_booking_id"
  end

  create_table "bookings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.bigint "home_id", null: false
    t.string "state", default: "initial", null: false
    t.string "organisation"
    t.string "email"
    t.integer "customer_id"
    t.json "strategy_data"
    t.boolean "committed_request"
    t.text "cancellation_reason"
    t.datetime "request_deadline"
    t.integer "approximate_headcount"
    t.text "remarks"
    t.text "invoice_address"
    t.string "purpose"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "booking_agent_code"
    t.index ["home_id"], name: "index_bookings_on_home_id"
    t.index ["state"], name: "index_bookings_on_state"
  end

  create_table "contracts", force: :cascade do |t|
    t.uuid "booking_id"
    t.datetime "sent_at"
    t.datetime "signed_at"
    t.string "title"
    t.text "text"
    t.datetime "valid_from"
    t.datetime "valid_until"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["booking_id"], name: "index_contracts_on_booking_id"
  end

  create_table "customers", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "street_address"
    t.string "zipcode"
    t.string "city"
    t.boolean "reservations_allowed"
    t.string "phone"
    t.string "email", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_customers_on_email"
  end

  create_table "homes", force: :cascade do |t|
    t.string "name"
    t.string "ref"
    t.text "janitor"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ref"], name: "index_homes_on_ref", unique: true
  end

  create_table "invoice_parts", force: :cascade do |t|
    t.bigint "invoice_id"
    t.bigint "usage_id"
    t.string "type"
    t.decimal "amount"
    t.text "text"
    t.integer "row_order"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["invoice_id"], name: "index_invoice_parts_on_invoice_id"
    t.index ["usage_id"], name: "index_invoice_parts_on_usage_id"
  end

  create_table "invoices", force: :cascade do |t|
    t.uuid "booking_id"
    t.datetime "issued_at"
    t.datetime "payable_until"
    t.text "text"
    t.integer "invoice_type"
    t.string "esr_number"
    t.decimal "amount", default: "0.0"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["booking_id"], name: "index_invoices_on_booking_id"
  end

  create_table "mailer_templates", force: :cascade do |t|
    t.string "mailer"
    t.string "action"
    t.string "locale"
    t.string "subject"
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "occupancies", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "begins_at", null: false
    t.datetime "ends_at", null: false
    t.bigint "home_id", null: false
    t.string "subject_type"
    t.string "subject_id"
    t.integer "occupancy_type", default: 0, null: false
    t.text "remarks"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["begins_at"], name: "index_occupancies_on_begins_at"
    t.index ["ends_at"], name: "index_occupancies_on_ends_at"
    t.index ["home_id"], name: "index_occupancies_on_home_id"
    t.index ["occupancy_type"], name: "index_occupancies_on_occupancy_type"
    t.index ["subject_type", "subject_id"], name: "index_occupancies_on_subject_type_and_subject_id"
  end

  create_table "tarif_usage_calculators", force: :cascade do |t|
    t.bigint "tarif_id"
    t.bigint "usage_calculator_id"
    t.boolean "perform_select", default: true
    t.boolean "perform_calculate", default: true
    t.string "distinction"
    t.jsonb "params"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tarif_id"], name: "index_tarif_usage_calculators_on_tarif_id"
    t.index ["usage_calculator_id"], name: "index_tarif_usage_calculators_on_usage_calculator_id"
  end

  create_table "tarifs", force: :cascade do |t|
    t.string "type"
    t.string "label"
    t.boolean "transient", default: false
    t.uuid "booking_id"
    t.bigint "home_id"
    t.bigint "booking_copy_template_id"
    t.string "unit"
    t.decimal "price_per_unit"
    t.datetime "valid_from", default: -> { "CURRENT_TIMESTAMP" }
    t.datetime "valid_until"
    t.integer "row_order"
    t.string "tarif_group"
    t.string "invoice_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["booking_copy_template_id"], name: "index_tarifs_on_booking_copy_template_id"
    t.index ["booking_id"], name: "index_tarifs_on_booking_id"
    t.index ["home_id"], name: "index_tarifs_on_home_id"
  end

  create_table "usage_calculators", force: :cascade do |t|
    t.bigint "home_id"
    t.string "type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["home_id"], name: "index_usage_calculators_on_home_id"
    t.index ["type"], name: "index_usage_calculators_on_type"
  end

  create_table "usages", force: :cascade do |t|
    t.bigint "tarif_id"
    t.decimal "used_units"
    t.text "remarks"
    t.uuid "booking_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["booking_id"], name: "index_usages_on_booking_id"
    t.index ["tarif_id"], name: "index_usages_on_tarif_id"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "role"
    t.string "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer "invitation_limit"
    t.string "invited_by_type"
    t.integer "invited_by_id"
    t.integer "invitations_count", default: 0
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["invitation_token"], name: "index_users_on_invitation_token", unique: true
    t.index ["invitations_count"], name: "index_users_on_invitations_count"
    t.index ["invited_by_id"], name: "index_users_on_invited_by_id"
    t.index ["invited_by_type", "invited_by_id"], name: "index_users_on_invited_by_type_and_invited_by_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "booking_transitions", "bookings"
  add_foreign_key "bookings", "homes"
  add_foreign_key "contracts", "bookings"
  add_foreign_key "invoice_parts", "invoices"
  add_foreign_key "invoice_parts", "usages"
  add_foreign_key "invoices", "bookings"
  add_foreign_key "occupancies", "homes"
  add_foreign_key "tarif_usage_calculators", "tarifs"
  add_foreign_key "tarif_usage_calculators", "usage_calculators"
  add_foreign_key "usage_calculators", "homes"
  add_foreign_key "usages", "bookings"
  add_foreign_key "usages", "tarifs"
end
