# frozen_string_literal: true

class AddOrdinalToCalendarLabels < ActiveRecord::Migration[8.1]
  def change
    add_column :calendar_labels, :ordinal, :integer
    add_index :calendar_labels, :ordinal
    add_index :tarifs, :ordinal
  end
end
