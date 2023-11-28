# frozen_string_literal: true

# == Schema Information
#
# Table name: rich_text_templates
#
#  id              :bigint           not null, primary key
#  body_i18n       :jsonb
#  enabled         :boolean          default(TRUE)
#  key             :string
#  title_i18n      :jsonb
#  type            :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  organisation_id :bigint           not null
#
# Indexes
#
#  index_rich_text_templates_on_key_and_organisation_id  (key,organisation_id) UNIQUE
#  index_rich_text_templates_on_organisation_id          (organisation_id)
#  index_rich_text_templates_on_type                     (type)
#
# Foreign Keys
#
#  fk_rails_...  (organisation_id => organisations.id)
#

require 'rails_helper'

RSpec.describe MailTemplate, type: :model do
  before { MailTemplate.define(key, **definition) }
  after { MailTemplate.undefine(key) }
  let(:definition) { { key: :test } }
  let(:key) { definition[:key] }
  let(:organisation) { create(:organisation) }
  let(:booking) { create(:booking, organisation:) }
  subject(:mail_template) { create(:mail_template, key:, organisation:) }

  describe '#use' do
    it { expect(mail_template.use(booking, to: :tenant)).to be_a(Notification) }
    it { expect(mail_template.use(booking, to: :tenant)).to be_valid }
    it { expect(mail_template.use(booking, to: :tenant, &:save)).to be_persisted }
  end
end
