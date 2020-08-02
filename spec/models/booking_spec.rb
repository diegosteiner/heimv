# frozen_string_literal: true

# == Schema Information
#
# Table name: bookings
#
#  id                    :uuid             not null, primary key
#  approximate_headcount :integer
#  cancellation_reason   :text
#  committed_request     :boolean
#  concluded             :boolean          default(FALSE)
#  editable              :boolean          default(TRUE)
#  email                 :string
#  import_data           :jsonb
#  internal_remarks      :text
#  invoice_address       :text
#  messages_enabled      :boolean          default(FALSE)
#  purpose               :string
#  ref                   :string
#  remarks               :text
#  state                 :string           default("initial"), not null
#  state_data            :json
#  tenant_organisation   :string
#  timeframe_locked      :boolean          default(FALSE)
#  usages_entered        :boolean          default(FALSE)
#  usages_presumed       :boolean          default(FALSE)
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  deadline_id           :bigint
#  home_id               :bigint           not null
#  occupancy_id          :uuid
#  organisation_id       :bigint           not null
#  tenant_id             :integer
#
# Indexes
#
#  index_bookings_on_deadline_id      (deadline_id)
#  index_bookings_on_home_id          (home_id)
#  index_bookings_on_organisation_id  (organisation_id)
#  index_bookings_on_ref              (ref)
#  index_bookings_on_state            (state)
#
# Foreign Keys
#
#  fk_rails_...  (home_id => homes.id)
#  fk_rails_...  (organisation_id => organisations.id)
#

require 'rails_helper'

describe Booking, type: :model do
  let(:organisation) { create(:organisation) }
  let(:tenant) { create(:tenant) }
  let(:home) { create(:home) }
  let(:booking) { build(:booking, tenant: tenant, home: home, organisation: organisation) }

  before do
    message_from_template = double('Message')
    allow(message_from_template).to receive(:deliver).and_return(true)
    allow(Message).to receive(:new_from_template).and_return(message_from_template)
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
      let(:existing_tenant) { create(:tenant, organisation: organisation) }
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
                                     tenant: tenant, home: home)
    end

    it 'creates all occupancy-related attributes in occupancy' do
      expect(booking).to be_valid
      expect(booking.save).to be true
      expect(booking.occupancy).not_to be_new_record
    end

    it 'creates all occupancy-related attributes in occupancy' do
      new_booking = described_class.create(booking_params)
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
