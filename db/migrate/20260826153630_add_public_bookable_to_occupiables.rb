# frozen_string_literal: true

class AddPublicBookableToOccupiables < ActiveRecord::Migration[8.1]
  def change
    add_column :occupiables, :bookable, :boolean, null: false, default: false

    reversible do |direction|
      direction.up do
        Occupiable.update_all(bookable: true) # rubocop:disable Rails/SkipsModelValidations
      end
    end
  end
end
