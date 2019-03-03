# == Schema Information
#
# Table name: organisations
#
#  id         :bigint(8)        not null, primary key
#  name       :string
#  ref        :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'rails_helper'

RSpec.describe Organisation, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
