# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ImportSeeder, type: :model do
  subject { described_class.new.seed }

  it { is_expected.to be(true) }
end
