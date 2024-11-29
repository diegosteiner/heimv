# frozen_string_literal: true

# == Schema Information
#
# Table name: meter_reading_periods
#
#  id          :integer          not null, primary key
#  tarif_id    :integer
#  usage_id    :integer
#  start_value :decimal(, )
#  end_value   :decimal(, )
#  begins_at   :datetime
#  ends_at     :datetime
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_meter_reading_periods_on_tarif_id  (tarif_id)
#  index_meter_reading_periods_on_usage_id  (usage_id)
#

require 'rails_helper'

RSpec.describe MeterReadingPeriod, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
