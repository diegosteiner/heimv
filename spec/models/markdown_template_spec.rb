# == Schema Information
#
# Table name: markdown_templates
#
#  id         :bigint(8)        not null, primary key
#  key        :string
#  title      :string
#  locale     :string
#  body       :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'rails_helper'

RSpec.describe MarkdownTemplate, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
