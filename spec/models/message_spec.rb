# == Schema Information
#
# Table name: messages
#
#  id                   :bigint           not null, primary key
#  booking_id           :uuid
#  markdown_template_id :bigint
#  sent_at              :datetime
#  subject              :string
#  body                 :text
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#

require 'rails_helper'

RSpec.describe Message, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
