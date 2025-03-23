class ImproveInvoiceNotificationTemplates < ActiveRecord::Migration[8.0]
  def change
    reversible do |direction|
      direction.up do
        rename_templates
        replace_liquid_templates
        remove_unused_templates
      end

      add_reference :contracts, :sent_with_notification, null: true, foreign_key: { to_table: :notifications }
      add_reference :invoices, :sent_with_notification, null: true, foreign_key: { to_table: :notifications }
    end
  end


  protected

  def rename_templates
    {
      awaiting_contract_notification: :email_contract_notification,
      payment_due_notification: :email_invoice_notification,
      operator_invoice_sent_notification: :operator_email_invoice_notification,
      operator_contract_sent_notification: :operator_email_contract_notification
    }.each { |old_key, new_key| RichTextTemplate.where(key: :old_key).update_all(key: new_key) }
  end

  def replace_liquid_templates
#   ... # {{ invoices[0] }} usw.
  end

  def remove_unused_templates
    # RichTextTemplate.where.not(key: RichTextTemplate.definitions.values.flatten)
  end
end
