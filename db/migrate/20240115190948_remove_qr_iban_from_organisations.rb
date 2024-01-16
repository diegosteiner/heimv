class RemoveQrIBANFromOrganisations < ActiveRecord::Migration[7.1]
  def change
    reversible do |direction|
      direction.up do
        Organisation.where.not(qr_iban: nil).find_each do |organisation|
          organisation.update(iban: organisation.qr_iban)
        end
      end
    end

    remove_column :organisations, :qr_iban, :string
  end
end
