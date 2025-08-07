# frozen_string_literal: true

# class CleanupOldData < ActiveRecord::Migration[7.1]
#   def up
#     remove_column :designated_documents, :send_with_contract, :boolean, default: false
#     remove_column :designated_documents, :send_with_last_infos, :boolean, default: false
#     remove_column :designated_documents, :send_with_accepted, :boolean, default: false
#     remove_column :bookings, :booking_questions, :jsonb
#     remove_column :occupiables, :janitor, :text
#     remove_column :journal_entry_batches, :fragments
#     remove_table :bookable_extras
#     remove_table :booked_extras
#     remove_table :invoice_parts
#     remove_table :invoice_parts
#   end
# end
