# frozen_string_literal: true

# == Schema Information
#
# Table name: bookable_extras
#
#  id               :bigint           not null, primary key
#  description_i18n :jsonb
#  key              :string
#  title_i18n       :jsonb
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  home_id          :bigint           not null
#  organisation_id  :bigint           not null
#
# Indexes
#
#  index_bookable_extras_on_home_id          (home_id)
#  index_bookable_extras_on_organisation_id  (organisation_id)
#
# Foreign Keys
#
#  fk_rails_...  (home_id => homes.id)
#  fk_rails_...  (organisation_id => organisations.id)
#
require 'rails_helper'

RSpec.describe BookableExtra, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
