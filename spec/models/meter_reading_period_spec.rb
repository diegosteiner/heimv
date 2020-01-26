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
# Indexes
#
#  index_meter_reading_periods_on_tarif_id  (tarif_id)
#  index_meter_reading_periods_on_usage_id  (usage_id)
#
# Foreign Keys
#
#  fk_rails_...  (tarif_id => tarifs.id)
#  fk_rails_...  (usage_id => usages.id)
#

require 'rails_helper'

RSpec.describe MeterReadingPeriod, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
