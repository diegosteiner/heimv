# frozen_string_literal: true

class AddCcToNotifications < ActiveRecord::Migration[8.1]
  def change
    change_table :notifications, bulk: true do |t|
      t.column :cc, :string, null: true
      t.column :deliver_cc, :string, array: true, default: []
    end
  end
end
