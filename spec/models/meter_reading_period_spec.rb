# == Schema Information
#
# Table name: meter_reading_periods
#
#  id          :bigint(8)        not null, primary key
#  tarif_id    :bigint(8)
#  usage_id    :bigint(8)
#  start_value :decimal(, )
#  end_value   :decimal(, )
#  begins_at   :datetime
#  ends_at     :datetime
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

require 'rails_helper'

RSpec.describe MeterReadingPeriod, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
