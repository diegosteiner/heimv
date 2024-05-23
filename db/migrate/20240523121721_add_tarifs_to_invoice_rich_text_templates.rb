class AddTarifsToInvoiceRichTextTemplates < ActiveRecord::Migration[7.1]
  Rails.application.eager_load!

  def up
    replace_in_contract_templates
    replace_in_invoice_templates
  end

  def replace_in_invoice_templates
    key = %i[invoices_invoice_text invoices_late_notice_text invoices_deposit_text invoices_offer_text]
    RichTextTemplate.where(key:).find_each do |rich_text_template|
      rich_text_template.body_i18n.transform_values! { _1 << "\n\n{{ TARIFS }}" }
      rich_text_template.save!
    end
  end

  def replace_in_contract_templates
    RichTextTemplate.where(key: :contract_text).find_each do |rich_text_template|
      rich_text_template.replace_in_body("{{ tarifs_table_placeholder }}", "{{ TARIFS }}")
      rich_text_template.save!
    end
  end
end
