# == Schema Information
#
# Table name: messages
#
#  id                   :bigint           not null, primary key
#  addressed_to         :integer          default("manager"), not null
#  body                 :text
#  sent_at              :datetime
#  subject              :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  booking_id           :uuid
#  markdown_template_id :bigint
#
# Indexes
#
#  index_messages_on_booking_id            (booking_id)
#  index_messages_on_markdown_template_id  (markdown_template_id)
#
# Foreign Keys
#
#  fk_rails_...  (booking_id => bookings.id)
#  fk_rails_...  (markdown_template_id => markdown_templates.id)
#

require 'rails_helper'

RSpec.describe Message, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
