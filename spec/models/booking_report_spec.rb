# == Schema Information
#
# Table name: reports
#
#  id            :bigint           not null, primary key
#  type          :string
#  label         :string
#  filter_params :jsonb
#  report_params :jsonb
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

require 'rails_helper'

RSpec.describe BookingReport, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
