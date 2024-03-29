class InitSchema < ActiveRecord::Migration[6.0]
  def up
    # These are extensions that must be enabled in order to support this database
    enable_extension "pgcrypto"
    enable_extension "plpgsql"
    enable_extension "uuid-ossp"
    create_table "active_storage_attachments" do |t|
      t.string "name", null: false
      t.string "record_type", null: false
      t.bigint "record_id", null: false
      t.bigint "blob_id", null: false
      t.datetime "created_at", precision: nil, null: false
      t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
      t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
    end
    create_table "active_storage_blobs" do |t|
      t.string "key", null: false
      t.string "filename", null: false
      t.string "content_type"
      t.text "metadata"
      t.bigint "byte_size", null: false
      t.string "checksum", null: false
      t.datetime "created_at", precision: nil, null: false
      t.string "service_name", null: false
      t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
    end
    create_table "active_storage_variant_records" do |t|
      t.bigint "blob_id", null: false
      t.string "variation_digest", null: false
      t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
    end
    create_table "agent_bookings", id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.uuid "booking_id"
      t.string "booking_agent_code"
      t.string "booking_agent_ref"
      t.boolean "committed_request"
      t.boolean "accepted_request"
      t.text "remarks"
      t.datetime "created_at", precision: nil, null: false
      t.datetime "updated_at", precision: nil, null: false
      t.bigint "home_id"
      t.bigint "organisation_id"
      t.string "tenant_email"
      t.bigint "booking_agent_id", null: false
      t.string "token"
      t.index ["booking_agent_id"], name: "index_agent_bookings_on_booking_agent_id"
      t.index ["booking_id"], name: "index_agent_bookings_on_booking_id"
      t.index ["home_id"], name: "index_agent_bookings_on_home_id"
      t.index ["organisation_id"], name: "index_agent_bookings_on_organisation_id"
      t.index ["token"], name: "index_agent_bookings_on_token", unique: true
    end
    create_table "booking_agents" do |t|
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
    create_table "booking_purposes" do |t|
      t.bigint "organisation_id", null: false
      t.string "key"
      t.jsonb "title_i18n"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.integer "ordinal"
      t.index ["key", "organisation_id"], name: "index_booking_purposes_on_key_and_organisation_id", unique: true
      t.index ["ordinal"], name: "index_booking_purposes_on_ordinal"
      t.index ["organisation_id"], name: "index_booking_purposes_on_organisation_id"
    end
    create_table "booking_transitions" do |t|
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
      t.index ["booking_id"], name: "index_booking_transitions_on_booking_id"
    end
    create_table "bookings", id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.bigint "home_id", null: false
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
      t.string "purpose_key"
      t.string "ref"
      t.boolean "editable", default: true
      t.boolean "usages_entered", default: false
      t.boolean "notifications_enabled", default: false
      t.jsonb "import_data"
      t.datetime "created_at", precision: nil, null: false
      t.datetime "updated_at", precision: nil, null: false
      t.text "internal_remarks"
      t.boolean "concluded", default: false
      t.boolean "usages_presumed", default: false
      t.bigint "deadline_id"
      t.string "locale"
      t.integer "purpose_id"
      t.string "booking_flow_type"
      t.string "token"
      t.index ["booking_state_cache"], name: "index_bookings_on_booking_state_cache"
      t.index ["deadline_id"], name: "index_bookings_on_deadline_id"
      t.index ["home_id"], name: "index_bookings_on_home_id"
      t.index ["locale"], name: "index_bookings_on_locale"
      t.index ["organisation_id"], name: "index_bookings_on_organisation_id"
      t.index ["ref"], name: "index_bookings_on_ref"
      t.index ["token"], name: "index_bookings_on_token", unique: true
    end
    create_table "contracts" do |t|
      t.uuid "booking_id"
      t.date "sent_at"
      t.date "signed_at"
      t.text "text"
      t.datetime "valid_from", precision: nil, default: -> { "CURRENT_TIMESTAMP" }
      t.datetime "valid_until", precision: nil
      t.datetime "created_at", precision: nil, null: false
      t.datetime "updated_at", precision: nil, null: false
      t.index ["booking_id"], name: "index_contracts_on_booking_id"
    end
    create_table "data_digests" do |t|
      t.string "type"
      t.string "label"
      t.jsonb "prefilter_params", default: {}
      t.jsonb "data_digest_params", default: {}
      t.datetime "created_at", precision: nil, null: false
      t.datetime "updated_at", precision: nil, null: false
      t.bigint "organisation_id", null: false
      t.index ["organisation_id"], name: "index_data_digests_on_organisation_id"
    end
    create_table "deadlines" do |t|
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
    create_table "homes" do |t|
      t.bigint "organisation_id", null: false
      t.string "name"
      t.string "ref"
      t.text "address"
      t.text "janitor"
      t.boolean "requests_allowed", default: false
      t.datetime "created_at", precision: nil, null: false
      t.datetime "updated_at", precision: nil, null: false
      t.integer "min_occupation"
      t.integer "booking_margin", default: 0
      t.index ["organisation_id"], name: "index_homes_on_organisation_id"
      t.index ["ref", "organisation_id"], name: "index_homes_on_ref_and_organisation_id", unique: true
    end
    create_table "invoice_parts" do |t|
      t.bigint "invoice_id"
      t.bigint "usage_id"
      t.string "type"
      t.decimal "amount"
      t.string "label"
      t.string "breakdown"
      t.integer "ordinal"
      t.datetime "created_at", precision: nil, null: false
      t.datetime "updated_at", precision: nil, null: false
      t.index ["invoice_id"], name: "index_invoice_parts_on_invoice_id"
      t.index ["usage_id"], name: "index_invoice_parts_on_usage_id"
    end
    create_table "invoices" do |t|
      t.string "type"
      t.uuid "booking_id"
      t.datetime "issued_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }
      t.datetime "payable_until", precision: nil
      t.datetime "sent_at", precision: nil
      t.text "text"
      t.string "ref"
      t.decimal "amount", default: "0.0"
      t.boolean "print_payment_slip", default: false
      t.datetime "discarded_at", precision: nil
      t.datetime "created_at", precision: nil, null: false
      t.datetime "updated_at", precision: nil, null: false
      t.string "payment_info_type"
      t.decimal "amount_open"
      t.index ["booking_id"], name: "index_invoices_on_booking_id"
      t.index ["discarded_at"], name: "index_invoices_on_discarded_at"
      t.index ["ref"], name: "index_invoices_on_ref"
      t.index ["type"], name: "index_invoices_on_type"
    end
    create_table "meter_reading_periods" do |t|
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
    create_table "notifications" do |t|
      t.uuid "booking_id"
      t.bigint "rich_text_template_id"
      t.datetime "sent_at", precision: nil
      t.string "subject"
      t.text "body"
      t.datetime "created_at", precision: nil, null: false
      t.datetime "updated_at", precision: nil, null: false
      t.integer "addressed_to", default: 0, null: false
      t.string "to", default: [], array: true
      t.string "cc", default: [], array: true
      t.boolean "queued_for_delivery", default: false
      t.index ["booking_id"], name: "index_notifications_on_booking_id"
      t.index ["rich_text_template_id"], name: "index_notifications_on_rich_text_template_id"
    end
    create_table "occupancies", id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.datetime "begins_at", precision: nil, null: false
      t.datetime "ends_at", precision: nil, null: false
      t.bigint "home_id", null: false
      t.integer "occupancy_type", default: 0, null: false
      t.text "remarks"
      t.datetime "created_at", precision: nil, null: false
      t.datetime "updated_at", precision: nil, null: false
      t.uuid "booking_id"
      t.index ["begins_at"], name: "index_occupancies_on_begins_at"
      t.index ["ends_at"], name: "index_occupancies_on_ends_at"
      t.index ["home_id"], name: "index_occupancies_on_home_id"
      t.index ["occupancy_type"], name: "index_occupancies_on_occupancy_type"
    end
    create_table "offers" do |t|
      t.uuid "booking_id"
      t.text "text"
      t.datetime "valid_from", precision: nil, default: -> { "CURRENT_TIMESTAMP" }
      t.datetime "valid_until", precision: nil
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["booking_id"], name: "index_offers_on_booking_id"
    end
    create_table "operator_responsibilities" do |t|
      t.uuid "booking_id"
      t.bigint "operator_id", null: false
      t.integer "ordinal"
      t.integer "responsibility"
      t.text "remarks"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.bigint "home_id"
      t.bigint "organisation_id", null: false
      t.index ["booking_id"], name: "index_operator_responsibilities_on_booking_id"
      t.index ["home_id"], name: "index_operator_responsibilities_on_home_id"
      t.index ["operator_id"], name: "index_operator_responsibilities_on_operator_id"
      t.index ["ordinal"], name: "index_operator_responsibilities_on_ordinal"
      t.index ["organisation_id"], name: "index_operator_responsibilities_on_organisation_id"
      t.index ["responsibility"], name: "index_operator_responsibilities_on_responsibility"
    end
    create_table "operators" do |t|
      t.string "name"
      t.string "email"
      t.text "contact_info"
      t.bigint "organisation_id", null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["organisation_id"], name: "index_operators_on_organisation_id"
    end
    create_table "organisations" do |t|
      t.string "name"
      t.text "address"
      t.string "booking_flow_type"
      t.string "invoice_ref_strategy_type"
      t.string "esr_beneficiary_account"
      t.text "notification_footer"
      t.string "currency", default: "CHF"
      t.datetime "created_at", precision: nil, null: false
      t.datetime "updated_at", precision: nil, null: false
      t.string "iban"
      t.string "representative_address"
      t.string "email"
      t.integer "payment_deadline", default: 30, null: false
      t.string "location"
      t.boolean "notifications_enabled", default: true
      t.string "bcc"
      t.string "mail_from"
      t.string "slug"
      t.string "locale", default: "de"
      t.integer "homes_limit"
      t.integer "users_limit"
      t.jsonb "smtp_settings"
      t.string "esr_ref_prefix"
      t.string "default_payment_info_type"
      t.string "invoice_ref_template", default: "%<prefix>s%<home_id>03d%<tenant_id>06d%<invoice_id>07d"
      t.string "ref_template", default: "%<home_ref>s%<year>04d%<month>02d%<day>02d%<same_day_alpha>s"
      t.jsonb "settings", default: {}
      t.index ["slug"], name: "index_organisations_on_slug", unique: true
    end
    create_table "payments" do |t|
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
      t.index ["booking_id"], name: "index_payments_on_booking_id"
      t.index ["invoice_id"], name: "index_payments_on_invoice_id"
    end
    create_table "rich_text_templates" do |t|
      t.string "key"
      t.datetime "created_at", precision: nil, null: false
      t.datetime "updated_at", precision: nil, null: false
      t.bigint "organisation_id", null: false
      t.bigint "home_id"
      t.jsonb "title_i18n", default: {}
      t.jsonb "body_i18n", default: {}
      t.jsonb "body_i18n_markdown", default: {}
      t.index ["home_id"], name: "index_rich_text_templates_on_home_id"
      t.index ["key", "home_id", "organisation_id"], name: "index_rich_text_templates_on_key_and_home_and_organisation", unique: true
      t.index ["organisation_id"], name: "index_rich_text_templates_on_organisation_id"
    end
    create_table "tarif_selectors" do |t|
      t.bigint "tarif_id"
      t.boolean "veto", default: true
      t.string "distinction"
      t.datetime "created_at", precision: nil, null: false
      t.datetime "updated_at", precision: nil, null: false
      t.string "type"
      t.index ["tarif_id"], name: "index_tarif_selectors_on_tarif_id"
    end
    create_table "tarifs" do |t|
      t.string "type"
      t.boolean "transient", default: false
      t.uuid "booking_id"
      t.bigint "home_id"
      t.bigint "booking_copy_template_id"
      t.decimal "price_per_unit"
      t.datetime "valid_from", precision: nil, default: -> { "CURRENT_TIMESTAMP" }
      t.datetime "valid_until", precision: nil
      t.integer "ordinal"
      t.string "tarif_group"
      t.string "invoice_type"
      t.string "prefill_usage_method"
      t.datetime "created_at", precision: nil, null: false
      t.datetime "updated_at", precision: nil, null: false
      t.boolean "tenant_visible", default: true
      t.jsonb "label_i18n", default: {}
      t.jsonb "unit_i18n", default: {}
      t.index ["booking_copy_template_id"], name: "index_tarifs_on_booking_copy_template_id"
      t.index ["booking_id"], name: "index_tarifs_on_booking_id"
      t.index ["home_id"], name: "index_tarifs_on_home_id"
      t.index ["type"], name: "index_tarifs_on_type"
    end
    create_table "tenants" do |t|
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
      t.string "additional_address"
      t.boolean "allow_bookings_without_contract", default: false
      t.index ["email", "organisation_id"], name: "index_tenants_on_email_and_organisation_id", unique: true
      t.index ["email"], name: "index_tenants_on_email"
      t.index ["organisation_id"], name: "index_tenants_on_organisation_id"
      t.index ["search_cache"], name: "index_tenants_on_search_cache"
    end
    create_table "usages" do |t|
      t.bigint "tarif_id"
      t.decimal "used_units"
      t.text "remarks"
      t.uuid "booking_id"
      t.datetime "created_at", precision: nil, null: false
      t.datetime "updated_at", precision: nil, null: false
      t.decimal "presumed_used_units"
      t.index ["booking_id"], name: "index_usages_on_booking_id"
      t.index ["tarif_id", "booking_id"], name: "index_usages_on_tarif_id_and_booking_id", unique: true
    end
    create_table "users", id: :serial do |t|
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
      t.integer "role"
      t.bigint "organisation_id"
      t.index ["email"], name: "index_users_on_email", unique: true
      t.index ["organisation_id"], name: "index_users_on_organisation_id"
      t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    end
    add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
    add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
    add_foreign_key "agent_bookings", "booking_agents"
    add_foreign_key "agent_bookings", "bookings"
    add_foreign_key "agent_bookings", "homes"
    add_foreign_key "agent_bookings", "organisations"
    add_foreign_key "booking_agents", "organisations"
    add_foreign_key "booking_purposes", "organisations"
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
    add_foreign_key "meter_reading_periods", "tarifs"
    add_foreign_key "meter_reading_periods", "usages"
    add_foreign_key "notifications", "bookings"
    add_foreign_key "notifications", "rich_text_templates"
    add_foreign_key "occupancies", "homes"
    add_foreign_key "offers", "bookings"
    add_foreign_key "operator_responsibilities", "bookings"
    add_foreign_key "operator_responsibilities", "homes"
    add_foreign_key "operator_responsibilities", "operators"
    add_foreign_key "operator_responsibilities", "organisations"
    add_foreign_key "operators", "organisations"
    add_foreign_key "payments", "bookings"
    add_foreign_key "payments", "invoices"
    add_foreign_key "rich_text_templates", "homes"
    add_foreign_key "rich_text_templates", "organisations"
    add_foreign_key "tarif_selectors", "tarifs"
    add_foreign_key "tenants", "organisations"
    add_foreign_key "usages", "bookings"
    add_foreign_key "usages", "tarifs"
    add_foreign_key "users", "organisations"
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "The initial migration is not revertable"
  end
end
