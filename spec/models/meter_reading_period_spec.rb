# frozen_string_literal: true

# == Schema Information
#
# Table name: meter_reading_periods
#
#  id          :bigint           not null, primary key
#  begins_at   :datetime
#  end_value   :decimal(, )
#  ends_at     :datetime
#  start_value :decimal(, )
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  tarif_id    :bigint
#  usage_id    :bigint
#

require 'rails_helper'

RSpec.describe MeterReadingPeriod do
  pending "add some examples to (or delete) #{__FILE__}"
end
