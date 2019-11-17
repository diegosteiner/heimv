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

FactoryBot.define do
  factory :data_digest do
    organisation
    type { '' }
    booking_ids { 'MyString' }
    params { '' }
  end
end
