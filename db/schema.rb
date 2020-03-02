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

ActiveRecord::Schema.define(version: 2020_02_12_151710) do

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

  create_table "agent_bookings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "booking_id"
    t.string "booking_agent_code"
    t.string "booking_agent_ref"
    t.boolean "committed_request"
    t.boolean "accepted_request"
    t.text "remarks"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "home_id"
    t.bigint "organisation_id"
    t.string "tenant_email"
    t.index ["booking_id"], name: "index_agent_bookings_on_booking_id"
    t.index ["home_id"], name: "index_agent_bookings_on_home_id"
    t.index ["organisation_id"], name: "index_agent_bookings_on_organisation_id"
  end

  create_table "booking_agents", force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.string "email"
    t.text "address"
    t.decimal "provision"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "organisation_id", default: 1, null: false
    t.index ["code"], name: "index_booking_agents_on_code"
    t.index ["organisation_id"], name: "index_booking_agents_on_organisation_id"
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
    t.bigint "organisation_id", null: false
    t.string "state", default: "initial", null: false
    t.string "tenant_organisation"
    t.string "email"
    t.integer "tenant_id"
    t.json "state_data", default: {}
    t.boolean "committed_request"
    t.text "cancellation_reason"
    t.integer "approximate_headcount"
    t.text "remarks"
    t.text "invoice_address"
    t.string "purpose"
    t.string "ref"
    t.boolean "editable", default: true
    t.boolean "usages_entered", default: false
    t.boolean "messages_enabled", default: false
    t.jsonb "import_data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "internal_remarks"
    t.boolean "concluded", default: false
    t.uuid "occupancy_id"
    t.index ["home_id"], name: "index_bookings_on_home_id"
    t.index ["organisation_id"], name: "index_bookings_on_organisation_id"
    t.index ["ref"], name: "index_bookings_on_ref"
    t.index ["state"], name: "index_bookings_on_state"
  end

  create_table "contracts", force: :cascade do |t|
    t.uuid "booking_id"
    t.date "sent_at"
    t.date "signed_at"
    t.text "text"
    t.datetime "valid_from", default: -> { "CURRENT_TIMESTAMP" }
    t.datetime "valid_until"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["booking_id"], name: "index_contracts_on_booking_id"
  end

  create_table "data_digests", force: :cascade do |t|
    t.string "type"
    t.string "label"
    t.jsonb "filter_params", default: {}
    t.jsonb "data_digest_params", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "organisation_id", default: 1, null: false
    t.index ["organisation_id"], name: "index_data_digests_on_organisation_id"
  end

  create_table "deadlines", force: :cascade do |t|
    t.datetime "at"
    t.uuid "booking_id"
    t.string "responsible_type"
    t.bigint "responsible_id"
    t.integer "postponable_for", default: 0
    t.boolean "armed", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "remarks"
    t.index ["booking_id"], name: "index_deadlines_on_booking_id"
    t.index ["responsible_type", "responsible_id"], name: "index_deadlines_on_responsible_type_and_responsible_id"
  end

  create_table "homes", force: :cascade do |t|
    t.bigint "organisation_id", null: false
    t.string "name"
    t.string "ref"
    t.string "place"
    t.text "janitor"
    t.boolean "requests_allowed", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "min_occupation"
    t.index ["organisation_id"], name: "index_homes_on_organisation_id"
    t.index ["ref"], name: "index_homes_on_ref", unique: true
  end

  create_table "invoice_parts", force: :cascade do |t|
    t.bigint "invoice_id"
    t.bigint "usage_id"
    t.string "type"
    t.decimal "amount"
    t.string "label"
    t.string "label_2"
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["invoice_id"], name: "index_invoice_parts_on_invoice_id"
    t.index ["usage_id"], name: "index_invoice_parts_on_usage_id"
  end

  create_table "invoices", force: :cascade do |t|
    t.string "type"
    t.uuid "booking_id"
    t.datetime "issued_at", default: -> { "CURRENT_TIMESTAMP" }
    t.datetime "payable_until"
    t.datetime "sent_at"
    t.text "text"
    t.string "ref"
    t.decimal "amount", default: "0.0"
    t.boolean "paid", default: false
    t.boolean "print_payment_slip", default: false
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "payment_info_type"
    t.index ["booking_id"], name: "index_invoices_on_booking_id"
    t.index ["ref"], name: "index_invoices_on_ref"
    t.index ["type"], name: "index_invoices_on_type"
  end

  create_table "markdown_templates", force: :cascade do |t|
    t.string "key"
    t.string "title"
    t.string "locale"
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "organisation_id", default: 1, null: false
    t.index ["key"], name: "index_markdown_templates_on_key"
    t.index ["organisation_id"], name: "index_markdown_templates_on_organisation_id"
  end

  create_table "messages", force: :cascade do |t|
    t.uuid "booking_id"
    t.bigint "markdown_template_id"
    t.datetime "sent_at"
    t.string "subject"
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "addressed_to", default: 0, null: false
    t.index ["booking_id"], name: "index_messages_on_booking_id"
    t.index ["markdown_template_id"], name: "index_messages_on_markdown_template_id"
  end

  create_table "meter_reading_periods", force: :cascade do |t|
    t.bigint "tarif_id"
    t.bigint "usage_id"
    t.decimal "start_value"
    t.decimal "end_value"
    t.datetime "begins_at"
    t.datetime "ends_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tarif_id"], name: "index_meter_reading_periods_on_tarif_id"
    t.index ["usage_id"], name: "index_meter_reading_periods_on_usage_id"
  end

  create_table "occupancies", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "begins_at", null: false
    t.datetime "ends_at", null: false
    t.bigint "home_id", null: false
    t.string "booking_type"
    t.integer "occupancy_type", default: 0, null: false
    t.text "remarks"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["begins_at"], name: "index_occupancies_on_begins_at"
    t.index ["ends_at"], name: "index_occupancies_on_ends_at"
    t.index ["home_id"], name: "index_occupancies_on_home_id"
    t.index ["occupancy_type"], name: "index_occupancies_on_occupancy_type"
  end

  create_table "organisations", force: :cascade do |t|
    t.string "name"
    t.text "address"
    t.string "booking_strategy_type"
    t.string "invoice_ref_strategy_type"
    t.string "esr_participant_nr"
    t.text "message_footer"
    t.string "currency"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "iban"
    t.string "booking_ref_strategy_type"
    t.string "representative_address"
    t.string "email"
    t.integer "payment_deadline", default: 30, null: false
  end

  create_table "payments", force: :cascade do |t|
    t.decimal "amount"
    t.date "paid_at"
    t.string "ref"
    t.bigint "invoice_id"
    t.uuid "booking_id"
    t.jsonb "data"
    t.text "remarks"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "write_off", default: false, null: false
    t.index ["booking_id"], name: "index_payments_on_booking_id"
    t.index ["invoice_id"], name: "index_payments_on_invoice_id"
  end

  create_table "tarif_selectors", force: :cascade do |t|
    t.bigint "tarif_id"
    t.boolean "veto", default: true
    t.string "distinction"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "type"
    t.index ["tarif_id"], name: "index_tarif_selectors_on_tarif_id"
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
    t.integer "position"
    t.string "tarif_group"
    t.string "invoice_type"
    t.string "prefill_usage_method"
    t.string "meter"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["booking_copy_template_id"], name: "index_tarifs_on_booking_copy_template_id"
    t.index ["booking_id"], name: "index_tarifs_on_booking_id"
    t.index ["home_id"], name: "index_tarifs_on_home_id"
    t.index ["type"], name: "index_tarifs_on_type"
  end

  create_table "tenants", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "street_address"
    t.string "zipcode"
    t.string "city"
    t.string "country"
    t.boolean "reservations_allowed"
    t.boolean "email_verified", default: false
    t.text "phone"
    t.text "remarks"
    t.string "email", null: false
    t.text "search_cache", null: false
    t.date "birth_date"
    t.jsonb "import_data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "organisation_id", default: 1, null: false
    t.index ["email"], name: "index_tenants_on_email"
    t.index ["organisation_id"], name: "index_tenants_on_organisation_id"
    t.index ["search_cache"], name: "index_tenants_on_search_cache"
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
    t.bigint "organisation_id", default: 1, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["organisation_id"], name: "index_users_on_organisation_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "agent_bookings", "bookings"
  add_foreign_key "agent_bookings", "homes"
  add_foreign_key "agent_bookings", "organisations"
  add_foreign_key "booking_agents", "organisations"
  add_foreign_key "booking_transitions", "bookings"
  add_foreign_key "bookings", "homes"
  add_foreign_key "bookings", "organisations"
  add_foreign_key "contracts", "bookings"
  add_foreign_key "data_digests", "organisations"
  add_foreign_key "deadlines", "bookings"
  add_foreign_key "homes", "organisations"
  add_foreign_key "invoice_parts", "invoices"
  add_foreign_key "invoice_parts", "usages"
  add_foreign_key "invoices", "bookings"
  add_foreign_key "markdown_templates", "organisations"
  add_foreign_key "messages", "bookings"
  add_foreign_key "messages", "markdown_templates"
  add_foreign_key "meter_reading_periods", "tarifs"
  add_foreign_key "meter_reading_periods", "usages"
  add_foreign_key "occupancies", "homes"
  add_foreign_key "payments", "bookings"
  add_foreign_key "payments", "invoices"
  add_foreign_key "tarif_selectors", "tarifs"
  add_foreign_key "tenants", "organisations"
  add_foreign_key "usages", "bookings"
  add_foreign_key "usages", "tarifs"
  add_foreign_key "users", "organisations"
end
