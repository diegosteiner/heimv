class RenameAndAddRefs < ActiveRecord::Migration[8.0]
  def change
    rename_column :invoices, :ref, :payment_ref
    add_column :invoices, :accounting_ref, :string, null: true
    add_column :tenants, :accounting_ref, :string, null: true

    reversible do |direction|
      direction.up do
        backfill
      end
    end
  end

  def backfill
    Organisation.find_each(batch_size: 1) do |organisation|
      organisation.invoices.order(created_at: :ASC).each do |invoice|
        invoice.sequence_number
        invoice.generate_accounting_ref(force: true);
        # this will overwrite the payment ref and mess up all payments!
        # invoice.generate_payment_ref(force: true);
        invoice.skip_generate_pdf = true
        invoice.save!
      end
      organisation.tenants.order(created_at: :ASC).each do |tenant|
        tenant.sequence_number
        tenant.generate_accounting_ref(force: true)
        tenant.save!
      end
    end
  end
end
