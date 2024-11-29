# frozen_string_literal: true

# == Schema Information
#
# Table name: plan_b_backups
#
#  id              :integer          not null, primary key
#  organisation_id :integer          not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_plan_b_backups_on_organisation_id  (organisation_id)
#

FactoryBot.define do
  factory :plan_b_backup do
    organisation { nil }
  end
end
