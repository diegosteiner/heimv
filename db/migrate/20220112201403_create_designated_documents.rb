class CreateDesignatedDocuments < ActiveRecord::Migration[6.1]
  def change
    create_table :designated_documents do |t|
      t.integer :designation, null: true, unsigned: true
      t.string :locale, null: true
      t.text :remarks
      t.references :organisation, null: false, index: true
      t.references :home, null: true, index: true

      t.timestamps
    end
    add_index :designated_documents, %i[designation locale home_id organisation_id], unique: true,
                        name: "index_designated_documentss_on_designation_and_locale"

    reversible do |direction|
      direction.up do 
        Organisation.find_each do |organisation| 
          add_as_designated_document(organisation.terms_pdf&.blob, :terms, organisation)
          add_as_designated_document(organisation.privacy_statement_pdf&.blob, :privacy_statement, organisation)
        end

        Home.find_each do |home| 
          add_as_designated_document(home.house_rules&.blob, :house_rules, home)
        end
      end
    end
  end

  private

  def add_as_designated_document(file, designation, attached_to)
    return unless file.present? && designation.present?

    organisation = attached_to.is_a?(Organisation) ? attached_to : attached_to.organisation
    home = attached_to.is_a?(Home) ? attached_to : nil
    DesignatedDocument.create!(designation: designation.to_sym, file: file, organsation: organisation, home: home)
  end
end
