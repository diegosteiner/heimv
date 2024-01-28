class RemoveQrIBANFromOrganisations < ActiveRecord::Migration[7.1]
  def change
    reversible do |direction|
      direction.up do
        Organisation.find_each do |organisation|
          organisation.update(iban: organisation.qr_iban) if organisation.qr_iban.present?
        end
      end
    end

    remove_column :organisations, :qr_iban, :string
  end
end
