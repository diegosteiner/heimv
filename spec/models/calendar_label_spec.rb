# frozen_string_literal: true

require 'rails_helper'

# == Schema Information
#
# Table name: calendar_labels
#
#  id                       :bigint           not null, primary key
#  color                    :string           not null
#  description_i18n         :jsonb            not null
#  discarded_at             :datetime
#  occupancy_status_default :integer
#  title_i18n               :jsonb            not null
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  organisation_id          :bigint
#
RSpec.describe CalendarLabel do
  pending "add some examples to (or delete) #{__FILE__}"
end
