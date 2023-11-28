# frozen_string_literal: true

# == Schema Information
#
# Table name: bookings
#
#  id                     :uuid             not null, primary key
#  accept_conditions      :boolean          default(FALSE)
#  approximate_headcount  :integer
#  begins_at              :datetime
#  booking_flow_type      :string
#  booking_questions      :jsonb
#  booking_state_cache    :string           default("initial"), not null
#  cancellation_reason    :text
#  committed_request      :boolean
#  concluded              :boolean          default(FALSE)
#  conditions_accepted_at :datetime
#  editable               :boolean          default(TRUE)
#  email                  :string
#  ends_at                :datetime
#  ignore_conflicting     :boolean          default(FALSE), not null
#  import_data            :jsonb
#  internal_remarks       :text
#  invoice_address        :text
#  locale                 :string
#  notifications_enabled  :boolean          default(FALSE)
#  occupancy_color        :string
#  occupancy_type         :integer          default("free"), not null
#  purpose_description    :string
#  ref                    :string
#  remarks                :text
#  state_data             :json
#  tenant_organisation    :string
#  token                  :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  booking_category_id    :integer
#  deadline_id            :bigint
#  home_id                :integer          not null
#  organisation_id        :bigint           not null
#  tenant_id              :integer
#
# Indexes
#
#  index_bookings_on_booking_state_cache  (booking_state_cache)
#  index_bookings_on_deadline_id          (deadline_id)
#  index_bookings_on_locale               (locale)
#  index_bookings_on_organisation_id      (organisation_id)
#  index_bookings_on_ref                  (ref)
#  index_bookings_on_token                (token) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (organisation_id => organisations.id)
#

require 'rails_helper'

describe Booking, type: :model do
  let(:organisation) { home.organisation }
  let(:tenant) { create(:tenant, organisation:) }
  let(:home) { create(:home) }
  let(:booking) { build(:booking, tenant:, home:, organisation:) }

  describe '#locale' do
    it 'has default locale' do
      expect(booking.locale.to_sym).to eq(I18n.locale.to_sym)
    end

    it 'allows to change the locale' do
      locale = :fr
      booking.tenant.locale = locale
      booking.save!

      expect(booking.tenant).to be_locale_fr
      expect(booking.locale.to_sym).to eq(locale)
    end
  end

  describe '#roles' do
    subject(:roles) { booking.roles }
    before do
      booking.save
      booking.reload
    end

    it { expect(roles).to eq({ administration: organisation, tenant: booking.tenant }) }

    context 'with agent_booking' do
      let(:booking_agent) { create(:booking_agent, organisation:) }
      let!(:agent_booking) { create(:agent_booking, organisation:, booking:, booking_agent_code: booking_agent.code) }

      it { expect(roles[:booking_agent]).to eq(booking_agent) }
    end

    context 'with operator responsibilities' do
      let(:responsibilities) do
        {
          administration: create(:operator, organisation:),
          home_handover: create(:operator, organisation:),
          home_return: create(:operator, organisation:),
          billing: create(:operator, organisation:)
        }
      end
      before do
        responsibilities.each do |responsibility, operator|
          booking.operator_responsibilities.create(responsibility:, operator:)
        end
      end

      it do
        responsibilities.each do |responsibility, operator|
          expect(roles[responsibility].operator).to eq(operator)
        end
      end
    end
  end

  describe 'Tenant' do
    context 'with new tenant' do
      it 'uses existing tenant when email is correct' do
        booking.email = build(:tenant).email
        expect(booking.save).to be true
        expect(booking.tenant).not_to be_new_record
        expect(booking.tenant).to be_a Tenant
      end
    end

    context 'with existing tenant' do
      let(:booking) do
        build(:booking, tenant: nil, home:, organisation:, email: existing_tenant.email)
      end
      let(:existing_tenant) { create(:tenant, organisation:, email: 'test@example.com') }
      let(:tenant) { nil }

      it 'uses existing tenant when email is correct' do
        expect(booking.save).to be true
        expect(booking.tenant.id).to eq(existing_tenant.id)
      end
    end
  end
end
