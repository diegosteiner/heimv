# frozen_string_literal: true

class AddDiscardedAtToPayments < ActiveRecord::Migration[8.0]
  def change
    add_column :payments, :discarded_at, :datetime, null: true
  end
end
