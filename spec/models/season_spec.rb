# == Schema Information
#
# Table name: seasons
#
#  id                          :bigint           not null, primary key
#  begins_at                   :datetime         not null
#  discarded_at                :datetime
#  ends_at                     :datetime         not null
#  label_i18n                  :jsonb
#  max_bookings                :integer
#  max_occupied_days           :integer
#  public_occupancy_visibility :integer          not null
#  status                      :integer          not null
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  organisation_id             :bigint           not null
#
require 'rails_helper'

RSpec.describe Season, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
