class ReplaceBookingCopyTarifs < ActiveRecord::Migration[7.0]
  def change
    add_column :usages, :price_per_unit, :decimal, null: true

    pin_price_per_unit
    flatten_usage_tarifs

    # remove_reference :tarifs, :booking_copy_template, index: true, foreign_key: true
    # remove_foreign_key :tarifs, column: :booking_copy_template_id, to_table: :tarifs
    remove_column :tarifs, :booking_copy_template_id
  end

  private 

  def pin_price_per_unit
    reversible do |direction|
      direction.up do 
        Usage.find_each do |usage|
          usage.pin_price_per_unit && usage.save
        end
      end
    end
  end

  def flatten_usage_tarifs
    reversible do |direction|
      direction.up do 
        Tarif.where.not(booking_id: nil).find_each do |tarif|
          usage = Usage.find_by(booking_id: tarif.booking_id, tarif_id: tarif.id)
          usage&.update_columns(tarif_id: tarif.booking_copy_template_id)
          tarif.destroy
        end
      end
    end
  end
end
