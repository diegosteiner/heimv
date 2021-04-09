class RenameESRParticipantNrToESRAccountInOrganisation < ActiveRecord::Migration[6.1]
  def change
    rename_column :organisations, :esr_participant_nr, :esr_beneficiary_account
    add_column :organisations, :esr_ref_prefix, :string, null: true
  end
end
