# frozen_string_literal: true

# == Schema Information
#
# Table name: operator_responsibilities
#
#  id              :bigint           not null, primary key
#  ordinal         :integer
#  remarks         :text
#  responsibility  :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  booking_id      :uuid
#  home_id         :bigint
#  operator_id     :bigint           not null
#  organisation_id :bigint           not null
#
# Indexes
#
#  index_operator_responsibilities_on_booking_id       (booking_id)
#  index_operator_responsibilities_on_home_id          (home_id)
#  index_operator_responsibilities_on_operator_id      (operator_id)
#  index_operator_responsibilities_on_ordinal          (ordinal)
#  index_operator_responsibilities_on_organisation_id  (organisation_id)
#  index_operator_responsibilities_on_responsibility   (responsibility)
#
# Foreign Keys
#
#  fk_rails_...  (booking_id => bookings.id)
#  fk_rails_...  (home_id => homes.id)
#  fk_rails_...  (operator_id => operators.id)
#  fk_rails_...  (organisation_id => organisations.id)
#
require 'rails_helper'

RSpec.describe OperatorResponsibilityService, type: :model do
  subject(:service) { described_class.new(booking) }
  let(:home) { create(:home) }
  let(:organisation) { home.organisation }
  let(:operator) { create(:operator, organisation: organisation) }
  let(:booking) { create(:booking, organisation: organisation, home: home) }
  before do
    create_list(:operator_responsibility, 4, organisation: organisation, home: home, operator: operator,
                                             responsibility: :administration)
  end

  describe '#assign' do
    subject(:responsibility) { service.assign(:administration) }

    it { is_expected.to be_valid }
    it { expect(responsibility.booking).to eq(booking) }
    it { expect(responsibility.home).to eq(home) }
    it { expect(responsibility).to be_administration }
  end
end
