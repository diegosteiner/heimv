class ChangeBookingPurposeInTemplates < ActiveRecord::Migration[6.1]
  def change
    RichTextTemplate.replace_in_template!('purpose | booking_purpose', 'purpose.title')
  end
end
