# frozen_string_literal: true

class RemoveAccountAddressFromOrganisations < ActiveRecord::Migration[8.1]
  def change
    remove_column :organisations, :account_address, :string
  end
end
