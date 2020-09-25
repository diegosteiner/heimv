# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Manage::BookingSerializer, type: :model do
  subject { described_class.render_as_hash(booking) }
  let(:booking) { create(:booking) }

  it { is_expected.to include({ ref: booking.ref }) }

  # context 'with agent_booking' do
  #   let(:agent_booking) { create(:agent_booking) }
  #   let(:booking) { agent_booking.booking }

  #   it { is_expected.to include({ id: booking.id }) }
  # end
end
