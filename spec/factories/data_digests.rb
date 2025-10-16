# frozen_string_literal: true

# == Schema Information
#
# Table name: data_digests
#
#  id                      :bigint           not null, primary key
#  crunching_finished_at   :datetime
#  crunching_started_at    :datetime
#  data                    :jsonb
#  period_from             :datetime
#  period_to               :datetime
#  record_ids              :jsonb
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  data_digest_template_id :bigint           not null
#  organisation_id         :bigint           not null
#

FactoryBot.define do
  factory :data_digest do
    organisation
  end
end
