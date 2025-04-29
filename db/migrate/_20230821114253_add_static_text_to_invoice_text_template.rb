# frozen_string_literal: true

# class 20230821114253AddStaticTextToInvoiceTextTemplate < ActiveRecord::Migration[7.0]
#   def up
#     Rails.application.eager_load!

#     keys = %i[invoices_invoice_text invoices_late_notice_text invoices_deposit_text invoices_offer_text]
#     RichTextTemplate.where(key: keys).find_each do |rtt|
#       rtt.body_i18n.each_pair do |locale, body|
#         I18n.with_locale(locale) do
#           next if body.blank?

#           prepend = <<~PREPEND
#             <small>
#               #{::Booking.human_attribute_name(:ref)}: {{ booking.ref }}<br />
#               {%- if invoice.sent_at -%}
#                 <small>#{::Invoice.human_attribute_name(:sent_at)}: {{ invoice.sent_at | date_format }}<br />
#               {%- endif -%}
#               {%- if invoice.payable_until -%}
#                 <small>#{::Invoice.human_attribute_name(:payable_until)}: {{ invoice.payable_until | date_format }}<br />
#               {%- endif -%}
#             </small>
#           PREPEND

#           rtt.body_i18n[locale] = prepend + body
#         end
#       end
#       rtt.save!
#     end
#   end
# end
