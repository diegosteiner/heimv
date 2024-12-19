# frozen_string_literal: true

require 'rails_helper'

describe TafBlock, type: :model do
  subject(:taf_block) do
    described_class.new(:Blg, text: 'TAF is "great"', test: 1) do
      block(:Bk, test: 2)
    end
  end

  describe '#initialize' do
    it 'works as DSL' do
      expect(taf_block.type).to eq(:Blg)
      expect(taf_block.properties.transform_values(&:value)).to eq({ test: '1', text: '"TAF is ""great"""' })
      expect(taf_block.children.count).to eq(1)
      expect(taf_block.children.first.type).to eq(:Bk)
      expect(taf_block.children.first.properties.transform_values(&:value)).to eq({ test: '2' })
      expect(taf_block.children.first.children.count).to eq(0)
    end
  end

  describe '#serialize' do
    subject(:serialize) { taf_block.serialize.chomp }

    it 'returns serialized string' do
      is_expected.to eq(<<~TAF.chomp)
        {Blg
          text="TAF is ""great"""
          test=1

          {Bk
            test=2

          }
        }
      TAF
    end
  end

  context '::derive' do
    let(:organisation) { create(:organisation) }
    let(:booking) { create(:booking, organisation:) }
    let(:vat_category) { create(:vat_category, percentage: 3.8, accounting_vat_code: 'MwSt38', organisation:) }
    let(:currency) { organisation.currency }

    describe 'JournalEntry' do
      subject(:taf_block) { described_class.derive(journal_entry) }
      let(:journal_entry) do
        JournalEntry.new(account_nr: 1050, amount: 2091.75, date: Date.new(2024, 10, 5), source_document_ref: '1234',
                         side: :soll, vat_category:, booking:, currency:,
                         text: "Lorem ipsum\nSecond Line, but its longer than sixty \"chars\", OMG!")
      end

      it 'builds correctly' do
        is_expected.to be_a described_class
        expect(taf_block.to_s).to eq(<<~TAF.chomp)
          {Bk
            AccId=1050
            Date=05.10.2024
            TaxId="MwSt38"
            Text="Lorem ipsum"
            Text2="Second Line, but its longer than sixty ""chars"", "
            Type=0
            ValNt=2091.75

          }
        TAF
      end
    end

    describe 'JournalEntry' do
      subject(:taf_block) { described_class.derive(journal_entry) }
      let(:journal_entry) do
        JournalEntry.new(account_nr: 1050, amount: 2091.75, date: Date.new(2024, 10, 5), source_document_ref: '1234',
                         side: :soll, vat_category:, booking:, currency:,
                         text: "Lorem ipsum\nSecond Line, but its longer than sixty \"chars\", OMG!")
      end

      it 'builds correctly' do
        is_expected.to be_a described_class
        expect(taf_block.to_s).to eq(<<~TAF.chomp)
          {Bk
            AccId=1050
            Date=05.10.2024
            TaxId="MwSt38"
            Text="Lorem ipsum"
            Text2="Second Line, but its longer than sixty ""chars"", "
            Type=0
            ValNt=2091.75

          }
        TAF
      end
    end
  end
end
