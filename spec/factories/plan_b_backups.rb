# frozen_string_literal: true

# == Schema Information
#
# Table name: plan_b_backups
#
#  id              :bigint           not null, primary key
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  organisation_id :bigint           not null
#

FactoryBot.define do
  factory :plan_b_backup do
    organisation { nil }
  end
end
