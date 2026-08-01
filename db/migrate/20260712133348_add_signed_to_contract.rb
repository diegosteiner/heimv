# frozen_string_literal: true

class AddSignedToContract < ActiveRecord::Migration[8.1]
  def change
    add_column :contracts, :confirmed_at, :datetime
    rename_column :contracts, :signed_at, :tenant_signed_at

    reversible do |direction|
      direction.up do
        Contract.where.not(tenant_signed_at: nil).find_each do |contract|
          contract.update_columns(confirmed_at: contract.tenant_signed_at) # rubocop:disable Rails/SkipsModelValidations
        end
      end
    end
  end
end
