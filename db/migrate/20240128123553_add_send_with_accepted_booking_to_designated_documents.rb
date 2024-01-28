class AddSendWithAcceptedBookingToDesignatedDocuments < ActiveRecord::Migration[7.1]
  def change
    add_column :designated_documents, :send_with_accepted, :boolean, default: false, null: false
  end
end
