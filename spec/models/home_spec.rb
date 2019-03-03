# == Schema Information
#
# Table name: homes
#
#  id         :bigint(8)        not null, primary key
#  name       :string
#  ref        :string
#  place      :string
#  janitor    :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'rails_helper'

RSpec.describe Home, type: :model do
end
