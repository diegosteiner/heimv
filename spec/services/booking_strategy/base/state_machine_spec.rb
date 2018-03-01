require 'rails_helper'

describe BookingStrategy::Base::StateMachine do
  let(:object) { build_stubbed(:booking) }
  let(:state_machine) { described_class.new(object) }
end
