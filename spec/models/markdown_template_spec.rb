# == Schema Information
#
# Table name: markdown_templates
#
#  id              :bigint           not null, primary key
#  body            :text
#  key             :string
#  locale          :string
#  title           :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  organisation_id :bigint           default(1), not null
#
# Indexes
#
#  index_markdown_templates_on_key              (key)
#  index_markdown_templates_on_organisation_id  (organisation_id)
#
# Foreign Keys
#
#  fk_rails_...  (organisation_id => organisations.id)
#

require 'rails_helper'

RSpec.describe MarkdownTemplate, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
