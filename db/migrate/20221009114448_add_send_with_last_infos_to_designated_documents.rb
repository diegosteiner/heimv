class AddSendWithLastInfosToDesignatedDocuments < ActiveRecord::Migration[7.0]
  def change
    add_column :designated_documents, :send_with_last_infos, :boolean, default: false

    reversible do |direction|
      direction.up do
        DesignatedDocument.where(designation: :house_rules).update_all(send_with_last_infos: true)
      end
    end
  end
end
