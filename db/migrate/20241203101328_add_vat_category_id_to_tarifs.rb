class AddVatCategoryIdToTarifs < ActiveRecord::Migration[8.0]
  def change
    add_reference :tarifs, :vat_category, null: true, foreign_key: true
    add_reference :invoice_parts, :vat_category, null: true, foreign_key: true

    reversible do |direction|
      direction.up do
        Organisation.find_each do |organisation|
          organisation.tarifs.find_each { migrate_tarif(_1) }
        end
      end
    end

    remove_column :tarifs, :vat, :decimal
    remove_column :invoice_parts, :vat, :decimal
  end

  protected

  def migrate_tarif(tarif)
    return if !tarif.respond_to?(:vat) || tarif.vat.blank?

    vat_category = tarif.organisation.vat_categories.find_or_create_by!(percentage: tarif.vat)
    tarif.update(vat_category:)
    InvoicePart.where(id: tarif.usages.map(&:invoice_part_ids))
      .find_each { |invoice_part| invoice_part.update(vat_category:)  }
  end
end
