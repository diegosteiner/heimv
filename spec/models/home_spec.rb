# frozen_string_literal: true

# == Schema Information
#
# Table name: homes
#
#  id               :bigint           not null, primary key
#  address          :text
#  janitor          :text
#  name             :string
#  ref              :string
#  requests_allowed :boolean          default(FALSE)
#  settings         :jsonb
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  organisation_id  :bigint           not null
#
# Indexes
#
#  index_homes_on_organisation_id          (organisation_id)
#  index_homes_on_ref_and_organisation_id  (ref,organisation_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (organisation_id => organisations.id)
#

require 'rails_helper'

RSpec.describe Home, type: :model do
  describe '#settings' do
    let(:home) { build(:home) }
    subject(:settings) { home.settings }

    it do
      expect(settings.booking_window).to eq(30.months)
      expect(settings.awaiting_contract_deadline).to eq(10.days)
      expect(settings.overdue_request_deadline).to eq(3.days)
      expect(settings.unconfirmed_request_deadline).to eq(3.days)
      expect(settings.provisional_request_deadline).to eq(10.days)
      expect(settings.last_minute_warning).to eq(10.days)
      expect(settings.invoice_payment_deadline).to eq(30.days)
      expect(settings.deposit_payment_deadline).to eq(10.days)
      expect(settings.deadline_postponable_for).to eq(3.days)
      expect(settings.booking_margin).to eq(0)
    end
  end
end
