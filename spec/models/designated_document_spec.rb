# frozen_string_literal: true

# == Schema Information
#
# Table name: designated_documents
#
#  id                   :bigint           not null, primary key
#  attaching_condition  :jsonb
#  designation          :integer
#  locale               :string
#  name                 :string
#  remarks              :text
#  send_with_accepted   :boolean          default(FALSE), not null
#  send_with_contract   :boolean          default(FALSE), not null
#  send_with_last_infos :boolean          default(FALSE)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  organisation_id      :bigint           not null
#
require 'rails_helper'

RSpec.describe DesignatedDocument, type: :model do
  let(:organisation) { create(:organisation) }
  let(:home) { create(:home, organisation:) }
  let(:document) { build(:designated_document, organisation:) }
  let(:file) { Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/designated_document.txt'), 'text/plain') }

  describe '#designation' do
    it 'is undesigneted by default' do
      expect(document.designation).to be_nil
    end

    it 'keeps its designation' do
      document.terms!
      expect(document).to be_terms
      expect(document.designation.to_sym).to eq(:terms)
    end
  end

  describe '#file' do
    it 'allows file to be attached' do
      expect(document.file.attach(io: file, filename: 'designated_document.txt')).to be_truthy
      expect(document.save).to be_truthy
      expect(document.file).to be_attached
    end
  end

  describe '::locale' do
    subject(:with_locale) { described_class.with_locale(locale).where(organisation:) }

    let(:locale) { :de }
    let(:documents) do
      {
        with_matching_locale: create(:designated_document, organisation:, locale: :de),
        without_matching_locale: create(:designated_document, organisation:, locale: :fr),
        without_locale: create(:designated_document, organisation:, locale: nil)
      }
    end

    it do
      documents
      expect(subject).to include(documents[:with_matching_locale])
      expect(subject).to include(documents[:without_locale])
      expect(subject).not_to include(documents[:without_matching_locale])
    end
  end

  describe '::for_booking' do
    subject(:for_booking) { described_class.for_booking(booking) }

    let(:booking) { create(:booking, organisation:) }
    let(:conditions) do
      {
        always: BookingConditions::AlwaysApply.new(organisation:),
        wrong_home: BookingConditions::Occupiable.new(compare_value: home.id, compare_attribute: :home),
        correct_home: BookingConditions::Occupiable.new(compare_value: booking.home_id, compare_attribute: :home)
      }
    end

    let(:documents) do
      conditions.transform_values do |condition|
        create!(:designated_document, organisation:, attaching_condition: condition)
      end
    end

    it do
      documents

      expect(for_booking.count).to eq(2)
      expect(documents[:always].attach_to?(booking)).to be_truthy
      expect(documents[:correct_home].attach_to?(booking)).to be_truthy
      expect(documents[:wrong_home].attach_to?(booking)).to be_falsy
    end
  end
end
