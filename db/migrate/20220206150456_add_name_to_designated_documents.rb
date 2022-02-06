class AddNameToDesignatedDocuments < ActiveRecord::Migration[6.1]
  def change
    remove_index :designated_documents, name: "index_designated_documentss_on_designation_and_locale"
    add_column :designated_documents, :name, :string, null: true
    add_column :designated_documents, :send_with_contract, :boolean, null: false, default: false
  end
end
