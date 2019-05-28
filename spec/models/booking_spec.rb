# == Schema Information
#
# Table name: bookings
#
#  id                    :uuid             not null, primary key
#  home_id               :bigint           not null
#  organisation_id       :bigint           not null
#  state                 :string           default("initial"), not null
#  tenant_organisation   :string
#  email                 :string
#  tenant_id             :integer
#  state_data            :json
#  committed_request     :boolean
#  cancellation_reason   :text
#  approximate_headcount :integer
#  remarks               :text
#  invoice_address       :text
#  purpose               :string
#  ref                   :string
#  editable              :boolean          default(TRUE)
#  usages_entered        :boolean          default(FALSE)
#  messages_enabled      :boolean          default(FALSE)
#  import_data           :jsonb
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  booking_agent_code    :string
#  booking_agent_ref     :string
#

require 'rails_helper'

describe Booking, type: :model do
  let(:organisation) { create(:organisation) }
  let(:tenant) { create(:tenant) }
  let(:home) { create(:home) }
  let(:booking) { build(:booking, tenant: tenant, home: home, organisation: organisation) }
  before { allow(BookingMailer).to receive_message_chain(:new_booking, :deliver_now) }

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
      let(:existing_tenant) { create(:tenant) }
      let(:tenant) { nil }

      it 'uses existing tenant when email is correct' do
        booking.email = existing_tenant.email
        expect(booking.save).to be true
        expect(booking.tenant_id).to eq(existing_tenant.id)
      end
    end
  end

  describe 'Occupancy' do
    let(:booking_params) do
      attributes_for(:booking).merge(occupancy_attributes: attributes_for(:occupancy),
                                     tenant: tenant,
                                     home: home)
    end

    it 'creates all occupancy-related attributes in occupancy' do
      expect(booking).to be_valid
      expect(booking.save).to be true
      expect(booking.occupancy).not_to be_new_record
    end

    it 'creates all occupancy-related attributes in occupancy' do
      new_booking = Booking.create(booking_params)
      expect(new_booking).to be_truthy
      expect(new_booking.occupancy).not_to be_new_record
      expect(new_booking.occupancy.home).to eq(new_booking.home)
    end

    it 'updates all occupancy-related attributes in occupancy' do
      update_booking = create(:booking)
      expect(update_booking.update(booking_params)).to be true
    end
  end
end
