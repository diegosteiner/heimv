# frozen_string_literal: true

# == Schema Information
#
# Table name: rich_text_templates
#
#  id              :bigint           not null, primary key
#  autodeliver     :boolean          default(TRUE)
#  body_i18n       :jsonb
#  enabled         :boolean          default(TRUE)
#  key             :string
#  title_i18n      :jsonb
#  type            :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  organisation_id :bigint           not null
#

require 'rails_helper'

RSpec.describe MailTemplate do
  subject(:mail_template) { create(:mail_template, key:, organisation:) }

  before { described_class.define(key, **definition) }
  after { described_class.undefine(key) }

  let(:definition) { { key: :test } }
  let(:key) { definition[:key] }
  let(:organisation) { create(:organisation) }
  let(:booking) { create(:booking, organisation:) }

  describe '#use' do
    it { expect(mail_template.use(booking, to: :tenant)).to be_a(Notification) }
    it { expect(mail_template.use(booking, to: :tenant)).to be_valid }
    it { expect(mail_template.use(booking, to: :tenant, &:save)).to be_persisted }
  end

  describe '#use deduped' do
    subject(:deduped) do
      Notification.dedup(booking, to: %i[home_handover home_return]) do |to|
        mail_template.use(booking, to:)
      end
    end

    let(:operator) { create(:operator, organisation:) }

    before do
      booking.operator_responsibilities.create!(responsibility: :home_handover, operator:)
      booking.operator_responsibilities.create!(responsibility: :home_return, operator:)
    end

    it { is_expected.to match_array(have_attributes(deliver_to: [operator.email])) }
  end
end
