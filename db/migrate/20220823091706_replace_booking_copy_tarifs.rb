class ReplaceBookingCopyTarifs < ActiveRecord::Migration[7.0]
  def change
    add_column :usages, :price_per_unit, :decimal, null: true

    reversible do |direction|
      direction.up do 
        pin_price_per_unit
        flatten_usage_tarifs
      end
    end

    # remove_reference :tarifs, :booking_copy_template, index: true, foreign_key: true
    # remove_foreign_key :tarifs, column: :booking_copy_template_id, to_table: :tarifs
    remove_column :tarifs, :booking_copy_template_id
  end

  private 

  def pin_price_per_unit
    Usage.find_each do |usage|
      usage.pin_price_per_unit && usage.save
    end
  end

  def flatten_usage_tarifs
    Tarif.where.not(booking_id: nil).find_each do |tarif|
      usage = Usage.find_by(booking_id: tarif.booking_id, tarif_id: tarif.id)
      target_tarif_id = tarif.booking_copy_template_id
      other_usage = usage.booking.usages.where(tarif_id: target_tarif_id).take if usage.present?

      if other_usage.present?
        other_usage.destroy unless other_usage.used_units&.nonzero?
        usage.destroy unless other_usage.destroyed?
      end

      usage&.update_columns(tarif_id: target_tarif_id) unless usage&.destroyed?
      tarif.destroy
    end
  end
end
