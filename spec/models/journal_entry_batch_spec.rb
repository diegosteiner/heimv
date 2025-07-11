# frozen_string_literal: true

# == Schema Information
#
# Table name: journal_entry_batches
#
#  id           :bigint           not null, primary key
#  currency     :string           not null
#  date         :date             not null
#  entries      :jsonb
#  fragments    :jsonb
#  processed_at :datetime
#  ref          :string
#  text         :string
#  trigger      :integer          not null
#  type         :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  booking_id   :uuid             not null
#  invoice_id   :bigint
#  payment_id   :bigint
#

require 'rails_helper'

RSpec.describe JournalEntryBatch do # rubocop:disable RSpec/EmptyExampleGroup
  # describe '::Factory.build_with_payment_write_off' do
  #   subject(:journal_entry_batch) { builder.build_with_payment(payment) }

  #   context 'with normal payment' do
  #     let(:payment) { create(:payment, booking:, amount: 420.0, write_off: false, invoice: nil) }

  #     it 'creates new journal entry' do
  #       is_expected.to have_attributes(trigger: 'payment_created', amount: 420.0, processed?: false, payment:)
  #       expect(journal_entry_batch.entries).to contain_exactly(
  #         have_attributes(account_nr: '1050', haben_amount: 420.0, book_type: 'main'),
  #         have_attributes(account_nr: '1025', soll_amount: 420.0, book_type: 'main')
  #       )
  #     end
  #   end

  #   context 'with write off payment' do
  #     let(:payment) { create(:payment, booking:, amount: 420.0, write_off: true, invoice: nil) }

  #     it 'creates new journal entry' do
  #       is_expected.to have_attributes(trigger: 'payment_created', amount: 420.0, processed?: false, payment:)
  #       expect(journal_entry_batch.entries).to contain_exactly(
  #         have_attributes(account_nr: '6000', haben_amount: 420.0, book_type: 'main'),
  #         have_attributes(account_nr: '1050', soll_amount: 420.0, book_type: 'main')
  #       )
  #     end
  #   end
  # end
end
