class AddPaymentInformationToOrganisation < ActiveRecord::Migration[6.0]
  def change
    add_column :organisations, :iban, :string
    add_column :organisations, :booking_ref_strategy_type, :string
    rename_column :organisations, :account_nr, :esr_participant_nr
  end
end
