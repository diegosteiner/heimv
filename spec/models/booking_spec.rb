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
#  editable               :boolean
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
#  sequence_number        :integer
#  sequence_year          :integer
#  state_data             :json
#  tenant_organisation    :string
#  token                  :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  booking_category_id    :integer
#  home_id                :integer          not null
#  organisation_id        :bigint           not null
#  tenant_id              :integer
#

require 'rails_helper'

RSpec::Matchers.define :have_state do |expected|
  match do |actual|
    actual.booking_flow.in_state?(expected.to_s)
  end
end

describe Booking do
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

    it do
      expect(Booking::ROLES).to match_array(%i[organisation tenant booking_agent administration
                                               home_handover home_return billing])
    end

    context 'with agent_booking' do
      let(:booking_agent) { create(:booking_agent, organisation:) }

      before { create(:agent_booking, organisation:, booking:, booking_agent_code: booking_agent.code) }

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

  describe '#tenant' do
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
      let(:existing_tenant) { create(:tenant, organisation:, email: 'test@heimv.test') }
      let(:tenant) { nil }

      it 'uses existing tenant when email is correct' do
        expect(booking.save).to be true
        expect(booking.tenant.id).to eq(existing_tenant.id)
      end
    end
  end

  describe '#apply_transitions' do
    let(:target_state) { :open_request }

    it 'add an error when trying to transition into invalid state' do
      # booking.skip_infer_transitions = true
      expect(booking.apply_transitions(:nonexistent)).to be_falsy
      expect(booking.errors[:transition_to]).not_to be_empty
    end

    it 'transitions into valid state' do
      expect(booking).to be_valid
      expect(booking.save).to be true
      expect(booking.apply_transitions(target_state)).not_to be_falsy
      expect(booking).to have_state(target_state)
      expect(booking.booking_state.to_s).to eq(target_state.to_s)
    end
  end
end
