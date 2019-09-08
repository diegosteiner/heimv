# == Schema Information
#
# Table name: data_digests
#
#  id            :bigint           not null, primary key
#  type          :string
#  label         :string
#  filter_params :jsonb
#  data_digest_params :jsonb
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

require 'rails_helper'

RSpec.describe DataDigests::Booking, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
