# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_07_22_065453) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"
  enable_extension "uuid-ossp"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", precision: nil, null: false
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "agent_bookings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "booking_id"
    t.string "booking_agent_code"
    t.string "booking_agent_ref"
    t.boolean "committed_request"
    t.boolean "accepted_request"
    t.text "remarks"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.bigint "organisation_id"
    t.string "tenant_email"
    t.bigint "booking_agent_id", null: false
    t.string "token"
    t.text "tenant_infos"
    t.index ["booking_agent_id"], name: "index_agent_bookings_on_booking_agent_id"
    t.index ["booking_id"], name: "index_agent_bookings_on_booking_id"
    t.index ["organisation_id"], name: "index_agent_bookings_on_organisation_id"
    t.index ["token"], name: "index_agent_bookings_on_token", unique: true
  end

  create_table "bookable_extras", force: :cascade do |t|
    t.jsonb "title_i18n"
    t.jsonb "description_i18n"
    t.bigint "organisation_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organisation_id"], name: "index_bookable_extras_on_organisation_id"
  end

  create_table "booked_extras", force: :cascade do |t|
    t.uuid "booking_id", null: false
    t.bigint "bookable_extra_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bookable_extra_id"], name: "index_booked_extras_on_bookable_extra_id"
  end

  create_table "booking_agents", force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.string "email"
    t.text "address"
    t.decimal "provision"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.bigint "organisation_id", null: false
    t.integer "request_deadline_minutes", default: 14400
    t.index ["code", "organisation_id"], name: "index_booking_agents_on_code_and_organisation_id", unique: true
    t.index ["organisation_id"], name: "index_booking_agents_on_organisation_id"
  end

  create_table "booking_categories", force: :cascade do |t|
    t.bigint "organisation_id", null: false
    t.string "key"
    t.jsonb "title_i18n", default: {}, null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "ordinal"
    t.jsonb "description_i18n", default: {}, null: false
    t.datetime "discarded_at"
    t.index ["discarded_at"], name: "index_booking_categories_on_discarded_at"
    t.index ["key", "organisation_id"], name: "index_booking_categories_on_key_and_organisation_id", unique: true
    t.index ["ordinal"], name: "index_booking_categories_on_ordinal"
    t.index ["organisation_id"], name: "index_booking_categories_on_organisation_id"
  end

  create_table "booking_conditions", force: :cascade do |t|
    t.bigint "qualifiable_id"
    t.boolean "must_condition", default: true
    t.string "compare_value"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "type"
    t.string "qualifiable_type"
    t.bigint "organisation_id"
    t.string "group"
    t.string "compare_attribute"
    t.string "compare_operator"
    t.index ["organisation_id"], name: "index_booking_conditions_on_organisation_id"
    t.index ["qualifiable_id", "qualifiable_type", "group"], name: "index_booking_conditions_on_qualifiable"
    t.index ["qualifiable_id", "qualifiable_type"], name: "index_booking_conditions_on_qualifiable_id_and_qualifiable_type"
  end

  create_table "booking_logs", force: :cascade do |t|
    t.uuid "booking_id", null: false
    t.bigint "user_id"
    t.integer "trigger", null: false
    t.jsonb "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_booking_logs_on_user_id"
  end

  create_table "booking_question_responses", force: :cascade do |t|
    t.uuid "booking_id", null: false
    t.bigint "booking_question_id", null: false
    t.jsonb "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["booking_question_id"], name: "index_booking_question_responses_on_booking_question_id"
  end

  create_table "booking_questions", force: :cascade do |t|
    t.bigint "organisation_id", null: false
    t.datetime "discarded_at"
    t.jsonb "label_i18n", default: {}, null: false
    t.jsonb "description_i18n", default: {}, null: false
    t.string "type"
    t.integer "ordinal"
    t.string "key"
    t.boolean "required", default: false
    t.jsonb "options"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "tenant_mode", default: 0, null: false
    t.integer "booking_agent_mode", default: 0
    t.jsonb "applying_conditions"
    t.index ["discarded_at"], name: "index_booking_questions_on_discarded_at"
    t.index ["organisation_id"], name: "index_booking_questions_on_organisation_id"
    t.index ["type"], name: "index_booking_questions_on_type"
  end

  create_table "booking_state_transitions", force: :cascade do |t|
    t.string "to_state", null: false
    t.integer "sort_key", null: false
    t.uuid "booking_id", null: false
    t.boolean "most_recent", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.json "metadata", default: {}
    t.json "booking_data", default: {}
    t.index ["booking_id", "most_recent"], name: "index_booking_transitions_parent_most_recent", unique: true, where: "most_recent"
    t.index ["booking_id", "sort_key"], name: "index_booking_transitions_parent_sort", unique: true
    t.index ["booking_id"], name: "index_booking_state_transitions_on_booking_id"
  end

  create_table "booking_validations", force: :cascade do |t|
    t.bigint "organisation_id", null: false
    t.jsonb "error_message_i18n", default: {}, null: false
    t.integer "ordinal"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "check_on", default: 0, null: false
    t.jsonb "validating_conditions"
    t.jsonb "enabling_conditions"
    t.index ["organisation_id"], name: "index_booking_validations_on_organisation_id"
  end

  create_table "bookings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.bigint "organisation_id", null: false
    t.string "booking_state_cache", default: "initial", null: false
    t.string "tenant_organisation"
    t.string "email"
    t.integer "tenant_id"
    t.json "state_data", default: {}
    t.boolean "committed_request"
    t.text "cancellation_reason"
    t.integer "approximate_headcount"
    t.text "remarks"
    t.text "invoice_address"
    t.string "ref"
    t.boolean "editable"
    t.boolean "notifications_enabled", default: false
    t.jsonb "import_data"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.text "internal_remarks"
    t.boolean "concluded", default: false
    t.string "locale"
    t.integer "booking_category_id"
    t.string "booking_flow_type"
    t.string "token"
    t.datetime "conditions_accepted_at", precision: nil
    t.string "occupancy_color"
    t.string "purpose_description"
    t.boolean "accept_conditions", default: false
    t.datetime "begins_at"
    t.datetime "ends_at"
    t.integer "occupancy_type", default: 0, null: false
    t.integer "home_id", null: false
    t.boolean "ignore_conflicting", default: false, null: false
    t.jsonb "booking_questions"
    t.integer "sequence_number"
    t.integer "sequence_year"
    t.index ["booking_state_cache"], name: "index_bookings_on_booking_state_cache"
    t.index ["locale"], name: "index_bookings_on_locale"
    t.index ["organisation_id"], name: "index_bookings_on_organisation_id"
    t.index ["ref"], name: "index_bookings_on_ref"
    t.index ["token"], name: "index_bookings_on_token", unique: true
  end

  create_table "contracts", force: :cascade do |t|
    t.uuid "booking_id"
    t.date "sent_at"
    t.date "signed_at"
    t.text "text"
    t.datetime "valid_from", precision: nil, default: -> { "CURRENT_TIMESTAMP" }
    t.datetime "valid_until", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "locale"
    t.bigint "sent_with_notification_id"
    t.index ["booking_id"], name: "index_contracts_on_booking_id"
    t.index ["sent_with_notification_id"], name: "index_contracts_on_sent_with_notification_id"
  end

  create_table "data_digest_templates", force: :cascade do |t|
    t.string "type"
    t.string "label"
    t.jsonb "prefilter_params", default: {}
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.bigint "organisation_id", null: false
    t.jsonb "columns_config"
    t.string "group"
    t.index ["organisation_id"], name: "index_data_digest_templates_on_organisation_id"
  end

  create_table "data_digests", force: :cascade do |t|
    t.bigint "data_digest_template_id", null: false
    t.bigint "organisation_id", null: false
    t.datetime "period_from", precision: nil
    t.datetime "period_to", precision: nil
    t.jsonb "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "crunching_started_at"
    t.datetime "crunching_finished_at"
    t.index ["data_digest_template_id"], name: "index_data_digests_on_data_digest_template_id"
    t.index ["organisation_id"], name: "index_data_digests_on_organisation_id"
  end

  create_table "deadlines", force: :cascade do |t|
    t.datetime "at", precision: nil
    t.uuid "booking_id"
    t.string "responsible_type"
    t.bigint "responsible_id"
    t.integer "postponable_for", default: 0
    t.boolean "armed", default: true
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.text "remarks"
    t.index ["booking_id"], name: "index_deadlines_on_booking_id"
    t.index ["responsible_type", "responsible_id"], name: "index_deadlines_on_responsible"
  end

  create_table "designated_documents", force: :cascade do |t|
    t.integer "designation"
    t.string "locale"
    t.text "remarks"
    t.bigint "organisation_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.boolean "send_with_contract", default: false, null: false
    t.boolean "send_with_last_infos", default: false
    t.boolean "send_with_accepted", default: false, null: false
    t.jsonb "attaching_conditions"
    t.index ["organisation_id"], name: "index_designated_documents_on_organisation_id"
  end

  create_table "invoice_parts", force: :cascade do |t|
    t.bigint "invoice_id"
    t.bigint "usage_id"
    t.string "type"
    t.decimal "amount"
    t.string "label"
    t.string "breakdown"
    t.integer "ordinal"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.bigint "vat_category_id"
    t.string "accounting_account_nr"
    t.string "accounting_cost_center_nr"
    t.index ["invoice_id"], name: "index_invoice_parts_on_invoice_id"
    t.index ["usage_id"], name: "index_invoice_parts_on_usage_id"
    t.index ["vat_category_id"], name: "index_invoice_parts_on_vat_category_id"
  end

  create_table "invoices", force: :cascade do |t|
    t.string "type"
    t.uuid "booking_id"
    t.datetime "issued_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }
    t.datetime "payable_until", precision: nil
    t.datetime "sent_at", precision: nil
    t.text "text"
    t.string "payment_ref"
    t.decimal "amount", default: "0.0"
    t.datetime "discarded_at", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "payment_info_type"
    t.decimal "amount_open"
    t.bigint "supersede_invoice_id"
    t.string "locale"
    t.boolean "payment_required", default: true
    t.integer "sequence_number"
    t.integer "sequence_year"
    t.string "ref"
    t.bigint "sent_with_notification_id"
    t.index ["booking_id"], name: "index_invoices_on_booking_id"
    t.index ["discarded_at"], name: "index_invoices_on_discarded_at"
    t.index ["payment_ref"], name: "index_invoices_on_payment_ref"
    t.index ["sent_with_notification_id"], name: "index_invoices_on_sent_with_notification_id"
    t.index ["supersede_invoice_id"], name: "index_invoices_on_supersede_invoice_id"
    t.index ["type"], name: "index_invoices_on_type"
  end

  create_table "journal_entry_batches", force: :cascade do |t|
    t.bigint "invoice_id"
    t.date "date", null: false
    t.string "currency", null: false
    t.string "ref"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "payment_id"
    t.integer "trigger", null: false
    t.uuid "booking_id", null: false
    t.datetime "processed_at"
    t.jsonb "fragments"
    t.string "text"
    t.jsonb "entries"
    t.string "type"
    t.index ["booking_id"], name: "index_journal_entry_batches_on_booking_id"
    t.index ["invoice_id"], name: "index_journal_entry_batches_on_invoice_id"
    t.index ["payment_id"], name: "index_journal_entry_batches_on_payment_id"
  end

  create_table "key_sequences", force: :cascade do |t|
    t.string "key", null: false
    t.bigint "organisation_id", null: false
    t.integer "year"
    t.integer "value", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key", "year", "organisation_id"], name: "index_key_sequences_on_key_and_year_and_organisation_id", unique: true
    t.index ["organisation_id"], name: "index_key_sequences_on_organisation_id"
  end

  create_table "mail_template_designated_documents", id: false, force: :cascade do |t|
    t.bigint "mail_template_id"
    t.bigint "designated_document_id"
    t.index ["designated_document_id"], name: "idx_on_designated_document_id_590865e4e7"
    t.index ["mail_template_id"], name: "index_mail_template_designated_documents_on_mail_template_id"
  end

  create_table "meter_reading_periods", force: :cascade do |t|
    t.bigint "tarif_id"
    t.bigint "usage_id"
    t.decimal "start_value"
    t.decimal "end_value"
    t.datetime "begins_at", precision: nil
    t.datetime "ends_at", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["tarif_id"], name: "index_meter_reading_periods_on_tarif_id"
    t.index ["usage_id"], name: "index_meter_reading_periods_on_usage_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.uuid "booking_id"
    t.bigint "mail_template_id"
    t.datetime "sent_at", precision: nil
    t.string "subject"
    t.text "body"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "deliver_to", default: [], array: true
    t.string "to"
    t.datetime "delivered_at"
    t.index ["booking_id"], name: "index_notifications_on_booking_id"
    t.index ["mail_template_id"], name: "index_notifications_on_mail_template_id"
  end

  create_table "oauth_tokens", force: :cascade do |t|
    t.bigint "organisation_id", null: false
    t.integer "audience", null: false
    t.string "access_token"
    t.string "refresh_token"
    t.string "token_type"
    t.datetime "expires_at"
    t.string "client_id"
    t.string "client_secret"
    t.string "authorize_url"
    t.string "token_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organisation_id"], name: "index_oauth_tokens_on_organisation_id"
  end

  create_table "occupancies", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "begins_at", precision: nil, null: false
    t.datetime "ends_at", precision: nil, null: false
    t.bigint "occupiable_id", null: false
    t.integer "occupancy_type", default: 0, null: false
    t.text "remarks"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.uuid "booking_id"
    t.string "color"
    t.boolean "linked", default: true
    t.boolean "ignore_conflicting", default: false, null: false
    t.index ["begins_at"], name: "index_occupancies_on_begins_at"
    t.index ["ends_at"], name: "index_occupancies_on_ends_at"
    t.index ["occupancy_type"], name: "index_occupancies_on_occupancy_type"
    t.index ["occupiable_id"], name: "index_occupancies_on_occupiable_id"
  end

  create_table "occupiables", force: :cascade do |t|
    t.bigint "organisation_id", null: false
    t.string "ref"
    t.text "janitor"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "type"
    t.boolean "occupiable", default: false
    t.bigint "home_id"
    t.jsonb "settings"
    t.integer "ordinal"
    t.jsonb "name_i18n", default: {}, null: false
    t.jsonb "description_i18n", default: {}, null: false
    t.datetime "discarded_at"
    t.index ["discarded_at"], name: "index_occupiables_on_discarded_at"
    t.index ["home_id"], name: "index_occupiables_on_home_id"
    t.index ["organisation_id"], name: "index_occupiables_on_organisation_id"
    t.index ["ref", "organisation_id"], name: "index_occupiables_on_ref_and_organisation_id", unique: true
  end

  create_table "operator_responsibilities", force: :cascade do |t|
    t.uuid "booking_id"
    t.bigint "operator_id", null: false
    t.integer "ordinal"
    t.integer "responsibility"
    t.text "remarks"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.bigint "organisation_id", null: false
    t.jsonb "assigning_conditions"
    t.index ["booking_id"], name: "index_operator_responsibilities_on_booking_id"
    t.index ["operator_id"], name: "index_operator_responsibilities_on_operator_id"
    t.index ["ordinal"], name: "index_operator_responsibilities_on_ordinal"
    t.index ["organisation_id"], name: "index_operator_responsibilities_on_organisation_id"
    t.index ["responsibility"], name: "index_operator_responsibilities_on_responsibility"
  end

  create_table "operators", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.text "contact_info"
    t.bigint "organisation_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "locale", null: false
    t.index ["organisation_id"], name: "index_operators_on_organisation_id"
  end

  create_table "organisation_users", force: :cascade do |t|
    t.bigint "organisation_id", null: false
    t.bigint "user_id", null: false
    t.integer "role", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "token"
    t.index ["organisation_id", "user_id"], name: "index_organisation_users_on_organisation_id_and_user_id", unique: true
    t.index ["organisation_id"], name: "index_organisation_users_on_organisation_id"
    t.index ["user_id"], name: "index_organisation_users_on_user_id"
  end

  create_table "organisations", force: :cascade do |t|
    t.string "name"
    t.text "address"
    t.string "booking_flow_type"
    t.string "esr_beneficiary_account"
    t.string "currency", default: "CHF"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "iban"
    t.string "representative_address"
    t.string "email"
    t.string "location"
    t.boolean "notifications_enabled", default: true
    t.string "bcc"
    t.string "mail_from"
    t.string "slug"
    t.string "locale"
    t.integer "homes_limit"
    t.integer "users_limit"
    t.jsonb "smtp_settings"
    t.string "esr_ref_prefix"
    t.string "default_payment_info_type"
    t.string "invoice_payment_ref_template", default: ""
    t.string "booking_ref_template", default: "%<home_ref>s%<year>04d%<month>02d%<day>02d%<same_ref_alpha>s"
    t.jsonb "settings", default: {}
    t.text "creditor_address"
    t.string "country_code", default: "CH", null: false
    t.string "account_address"
    t.text "cors_origins"
    t.jsonb "nickname_label_i18n", default: {}
    t.jsonb "accounting_settings", default: {}
    t.string "invoice_ref_template"
    t.string "tenant_ref_template"
    t.jsonb "booking_state_settings", default: {}
    t.jsonb "deadline_settings", default: {}
    t.index ["slug"], name: "index_organisations_on_slug", unique: true
  end

  create_table "payments", force: :cascade do |t|
    t.decimal "amount"
    t.date "paid_at"
    t.string "ref"
    t.bigint "invoice_id"
    t.uuid "booking_id"
    t.jsonb "data"
    t.text "remarks"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "write_off", default: false, null: false
    t.string "camt_instr_id"
    t.string "accounting_account_nr"
    t.string "accounting_cost_center_nr"
    t.index ["booking_id"], name: "index_payments_on_booking_id"
    t.index ["invoice_id"], name: "index_payments_on_invoice_id"
  end

  create_table "plan_b_backups", force: :cascade do |t|
    t.bigint "organisation_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organisation_id"], name: "index_plan_b_backups_on_organisation_id"
  end

  create_table "rich_text_templates", force: :cascade do |t|
    t.string "key"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.bigint "organisation_id", null: false
    t.jsonb "title_i18n", default: {}
    t.jsonb "body_i18n", default: {}
    t.boolean "enabled", default: true
    t.string "type"
    t.boolean "autodeliver", default: true
    t.index ["key", "organisation_id"], name: "index_rich_text_templates_on_key_and_organisation_id", unique: true
    t.index ["organisation_id"], name: "index_rich_text_templates_on_organisation_id"
    t.index ["type"], name: "index_rich_text_templates_on_type"
  end

  create_table "solid_queue_blocked_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "queue_name", null: false
    t.integer "priority", default: 0, null: false
    t.string "concurrency_key", null: false
    t.datetime "expires_at", null: false
    t.datetime "created_at", null: false
    t.index ["concurrency_key", "priority", "job_id"], name: "index_solid_queue_blocked_executions_for_release"
    t.index ["expires_at", "concurrency_key"], name: "index_solid_queue_blocked_executions_for_maintenance"
    t.index ["job_id"], name: "index_solid_queue_blocked_executions_on_job_id", unique: true
  end

  create_table "solid_queue_claimed_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.bigint "process_id"
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_claimed_executions_on_job_id", unique: true
    t.index ["process_id", "job_id"], name: "index_solid_queue_claimed_executions_on_process_id_and_job_id"
  end

  create_table "solid_queue_failed_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.text "error"
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_failed_executions_on_job_id", unique: true
  end

  create_table "solid_queue_jobs", force: :cascade do |t|
    t.string "queue_name", null: false
    t.string "class_name", null: false
    t.text "arguments"
    t.integer "priority", default: 0, null: false
    t.string "active_job_id"
    t.datetime "scheduled_at"
    t.datetime "finished_at"
    t.string "concurrency_key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active_job_id"], name: "index_solid_queue_jobs_on_active_job_id"
    t.index ["class_name"], name: "index_solid_queue_jobs_on_class_name"
    t.index ["finished_at"], name: "index_solid_queue_jobs_on_finished_at"
    t.index ["queue_name", "finished_at"], name: "index_solid_queue_jobs_for_filtering"
    t.index ["scheduled_at", "finished_at"], name: "index_solid_queue_jobs_for_alerting"
  end

  create_table "solid_queue_pauses", force: :cascade do |t|
    t.string "queue_name", null: false
    t.datetime "created_at", null: false
    t.index ["queue_name"], name: "index_solid_queue_pauses_on_queue_name", unique: true
  end

  create_table "solid_queue_processes", force: :cascade do |t|
    t.string "kind", null: false
    t.datetime "last_heartbeat_at", null: false
    t.bigint "supervisor_id"
    t.integer "pid", null: false
    t.string "hostname"
    t.text "metadata"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.index ["last_heartbeat_at"], name: "index_solid_queue_processes_on_last_heartbeat_at"
    t.index ["name", "supervisor_id"], name: "index_solid_queue_processes_on_name_and_supervisor_id", unique: true
    t.index ["supervisor_id"], name: "index_solid_queue_processes_on_supervisor_id"
  end

  create_table "solid_queue_ready_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "queue_name", null: false
    t.integer "priority", default: 0, null: false
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_ready_executions_on_job_id", unique: true
    t.index ["priority", "job_id"], name: "index_solid_queue_poll_all"
    t.index ["queue_name", "priority", "job_id"], name: "index_solid_queue_poll_by_queue"
  end

  create_table "solid_queue_recurring_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "task_key", null: false
    t.datetime "run_at", null: false
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_recurring_executions_on_job_id", unique: true
    t.index ["task_key", "run_at"], name: "index_solid_queue_recurring_executions_on_task_key_and_run_at", unique: true
  end

  create_table "solid_queue_recurring_tasks", force: :cascade do |t|
    t.string "key", null: false
    t.string "schedule", null: false
    t.string "command", limit: 2048
    t.string "class_name"
    t.text "arguments"
    t.string "queue_name"
    t.integer "priority", default: 0
    t.boolean "static", default: true, null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_solid_queue_recurring_tasks_on_key", unique: true
    t.index ["static"], name: "index_solid_queue_recurring_tasks_on_static"
  end

  create_table "solid_queue_scheduled_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "queue_name", null: false
    t.integer "priority", default: 0, null: false
    t.datetime "scheduled_at", null: false
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_scheduled_executions_on_job_id", unique: true
    t.index ["scheduled_at", "priority", "job_id"], name: "index_solid_queue_dispatch_all"
  end

  create_table "solid_queue_semaphores", force: :cascade do |t|
    t.string "key", null: false
    t.integer "value", default: 1, null: false
    t.datetime "expires_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["expires_at"], name: "index_solid_queue_semaphores_on_expires_at"
    t.index ["key", "value"], name: "index_solid_queue_semaphores_on_key_and_value"
    t.index ["key"], name: "index_solid_queue_semaphores_on_key", unique: true
  end

  create_table "tarifs", force: :cascade do |t|
    t.string "type"
    t.boolean "pin", default: true
    t.decimal "price_per_unit"
    t.datetime "valid_from", precision: nil, default: -> { "CURRENT_TIMESTAMP" }
    t.datetime "valid_until", precision: nil
    t.integer "ordinal"
    t.string "tarif_group"
    t.string "prefill_usage_method"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.jsonb "label_i18n", default: {}
    t.jsonb "unit_i18n", default: {}
    t.string "accounting_account_nr"
    t.integer "associated_types", default: 0, null: false
    t.decimal "minimum_usage_per_night"
    t.decimal "minimum_usage_total"
    t.bigint "organisation_id", null: false
    t.datetime "discarded_at"
    t.bigint "prefill_usage_booking_question_id"
    t.decimal "minimum_price_per_night"
    t.decimal "minimum_price_total"
    t.string "accounting_cost_center_nr"
    t.bigint "vat_category_id"
    t.jsonb "selecting_conditions"
    t.jsonb "enabling_conditions"
    t.index ["discarded_at"], name: "index_tarifs_on_discarded_at"
    t.index ["organisation_id"], name: "index_tarifs_on_organisation_id"
    t.index ["prefill_usage_booking_question_id"], name: "index_tarifs_on_prefill_usage_booking_question_id"
    t.index ["type"], name: "index_tarifs_on_type"
    t.index ["vat_category_id"], name: "index_tarifs_on_vat_category_id"
  end

  create_table "tenants", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "street_address"
    t.string "zipcode"
    t.string "city"
    t.boolean "reservations_allowed", default: true
    t.boolean "email_verified", default: false
    t.text "phone"
    t.text "remarks"
    t.string "email"
    t.text "search_cache", null: false
    t.date "birth_date"
    t.jsonb "import_data"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.bigint "organisation_id", null: false
    t.string "country_code", default: "CH"
    t.string "nickname"
    t.string "address_addon"
    t.boolean "bookings_without_contract", default: false
    t.string "locale"
    t.boolean "bookings_without_invoice", default: false
    t.integer "salutation_form"
    t.string "accounting_account_nr"
    t.integer "sequence_number"
    t.string "ref"
    t.index ["email", "organisation_id"], name: "index_tenants_on_email_and_organisation_id", unique: true
    t.index ["email"], name: "index_tenants_on_email"
    t.index ["organisation_id"], name: "index_tenants_on_organisation_id"
    t.index ["search_cache"], name: "index_tenants_on_search_cache"
  end

  create_table "usages", force: :cascade do |t|
    t.bigint "tarif_id"
    t.decimal "used_units"
    t.text "remarks"
    t.uuid "booking_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.decimal "presumed_used_units"
    t.boolean "committed", default: false
    t.decimal "price_per_unit"
    t.jsonb "details"
    t.index ["booking_id"], name: "index_usages_on_booking_id"
    t.index ["tarif_id", "booking_id"], name: "index_usages_on_tarif_id_and_booking_id", unique: true
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: nil
    t.datetime "remember_created_at", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "confirmation_token"
    t.datetime "confirmed_at", precision: nil
    t.datetime "confirmation_sent_at", precision: nil
    t.string "unconfirmed_email"
    t.bigint "default_organisation_id"
    t.boolean "role_admin", default: false
    t.string "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer "invitation_limit"
    t.string "invited_by_type"
    t.bigint "invited_by_id"
    t.integer "invitations_count", default: 0
    t.string "token"
    t.integer "default_calendar_view"
    t.index ["default_organisation_id"], name: "index_users_on_default_organisation_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["invitation_token"], name: "index_users_on_invitation_token", unique: true
    t.index ["invited_by_id"], name: "index_users_on_invited_by_id"
    t.index ["invited_by_type", "invited_by_id"], name: "index_users_on_invited_by"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "vat_categories", force: :cascade do |t|
    t.decimal "percentage", default: "0.0", null: false
    t.jsonb "label_i18n", default: {}, null: false
    t.bigint "organisation_id", null: false
    t.string "accounting_vat_code"
    t.datetime "discarded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["discarded_at"], name: "index_vat_categories_on_discarded_at"
    t.index ["organisation_id"], name: "index_vat_categories_on_organisation_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "agent_bookings", "booking_agents"
  add_foreign_key "agent_bookings", "bookings"
  add_foreign_key "agent_bookings", "organisations"
  add_foreign_key "bookable_extras", "organisations"
  add_foreign_key "booked_extras", "bookable_extras"
  add_foreign_key "booking_agents", "organisations"
  add_foreign_key "booking_categories", "organisations"
  add_foreign_key "booking_conditions", "organisations"
  add_foreign_key "booking_logs", "users"
  add_foreign_key "booking_question_responses", "booking_questions"
  add_foreign_key "booking_questions", "organisations"
  add_foreign_key "booking_state_transitions", "bookings"
  add_foreign_key "booking_validations", "organisations"
  add_foreign_key "bookings", "organisations"
  add_foreign_key "contracts", "bookings"
  add_foreign_key "contracts", "notifications", column: "sent_with_notification_id"
  add_foreign_key "data_digest_templates", "organisations"
  add_foreign_key "data_digests", "data_digest_templates"
  add_foreign_key "data_digests", "organisations"
  add_foreign_key "deadlines", "bookings"
  add_foreign_key "invoice_parts", "invoices"
  add_foreign_key "invoice_parts", "usages"
  add_foreign_key "invoice_parts", "vat_categories"
  add_foreign_key "invoices", "bookings"
  add_foreign_key "invoices", "invoices", column: "supersede_invoice_id"
  add_foreign_key "invoices", "notifications", column: "sent_with_notification_id"
  add_foreign_key "journal_entry_batches", "invoices"
  add_foreign_key "key_sequences", "organisations"
  add_foreign_key "mail_template_designated_documents", "designated_documents"
  add_foreign_key "mail_template_designated_documents", "rich_text_templates", column: "mail_template_id"
  add_foreign_key "meter_reading_periods", "tarifs"
  add_foreign_key "meter_reading_periods", "usages"
  add_foreign_key "notifications", "bookings"
  add_foreign_key "notifications", "rich_text_templates", column: "mail_template_id"
  add_foreign_key "oauth_tokens", "organisations"
  add_foreign_key "occupancies", "occupiables"
  add_foreign_key "occupiables", "organisations"
  add_foreign_key "operator_responsibilities", "bookings"
  add_foreign_key "operator_responsibilities", "operators"
  add_foreign_key "operator_responsibilities", "organisations"
  add_foreign_key "operators", "organisations"
  add_foreign_key "organisation_users", "organisations"
  add_foreign_key "organisation_users", "users"
  add_foreign_key "payments", "bookings"
  add_foreign_key "payments", "invoices"
  add_foreign_key "plan_b_backups", "organisations"
  add_foreign_key "rich_text_templates", "organisations"
  add_foreign_key "solid_queue_blocked_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_claimed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_failed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_ready_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_recurring_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_scheduled_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "tarifs", "booking_questions", column: "prefill_usage_booking_question_id"
  add_foreign_key "tarifs", "organisations"
  add_foreign_key "tarifs", "vat_categories"
  add_foreign_key "tenants", "organisations"
  add_foreign_key "usages", "bookings"
  add_foreign_key "usages", "tarifs"
  add_foreign_key "users", "organisations", column: "default_organisation_id"
  add_foreign_key "vat_categories", "organisations"
end
