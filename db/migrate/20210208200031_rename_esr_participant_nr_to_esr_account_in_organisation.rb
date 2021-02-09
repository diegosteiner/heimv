class RenameESRParticipantNrToESRAccountInOrganisation < ActiveRecord::Migration[6.1]
  def change
    rename_column :organisations, :esr_participant_nr, :esr_beneficiary_account
    add_column :organisations, :esr_ref_prefix, :string, null: true

    reversible do |direction|
      direction.up do 
        MarkdownTemplate.replace_in_template!('esr_participant_nr', 'esr_beneficiary_account')
      end
    end
  end
end
