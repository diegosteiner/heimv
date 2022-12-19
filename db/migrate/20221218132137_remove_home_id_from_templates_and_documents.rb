class RemoveHomeIdFromTemplatesAndDocuments < ActiveRecord::Migration[7.0]
  def change
    remove_foreign_key :booking_conditions, :tarifs, column: :qualifiable_id
    add_index :rich_text_templates, %i[key organisation_id], unique: true

    add_booking_conditions_for_designated_documents 

    remove_reference :rich_text_templates, :home
    remove_reference :designated_documents, :home
  end

  protected

  def add_booking_conditions_for_designated_documents
    DesignatedDocument.find_each do |document| 
      next if document.home_id.blank?

      document.attaching_conditions << BookingConditions::Occupiable.new(qualifiable: document, 
                                                                         distinction: document.home_id, 
                                                                         group: :attaching)
      document.save
    end
  end
end
