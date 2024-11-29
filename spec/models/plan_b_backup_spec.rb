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

require 'rails_helper'

RSpec.describe PlanBBackup, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
