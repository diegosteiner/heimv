class RenameAndAddRefs < ActiveRecord::Migration[8.0]
  def change
    rename_column :invoices, :ref, :payment_ref
    add_column :invoices, :ref, :string, null: true
    add_column :tenants, :ref, :string, null: true

    reversible do |direction|
      direction.up do
        Organisation.find_each do |organisation|
          backfill_invoices(organisation)
          backfill_tenants(organisation)
        end
      end
    end
  end

  def backfill_invoices(organisation)
    organisation.invoices.order(created_at: :ASC).each do |invoice|
      invoice.sequence_number
      invoice.generate_ref(force: true);
      # this will overwrite the payment ref and mess up all payments!
      # invoice.generate_payment_ref(force: true);
      invoice.skip_generate_pdf = true
      invoice.save!
    end
  end

  def backfill_tenants(organisation)
    organisation.tenants.order(created_at: :ASC).each do |tenant|
      tenant.sequence_number
      tenant.generate_ref(force: true)
      tenant.save!
    end
  end
end
