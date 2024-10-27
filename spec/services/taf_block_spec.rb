# frozen_string_literal: true

require 'rails_helper'

describe TafBlock, type: :model do
  subject(:taf_block) do
    described_class.new(:Blg, text: 'TAF is "great"') do |taf|
      taf.property test: 1
      taf.child described_class.new(:Bk, test: 2)
    end
  end

  describe '#initialize' do
    it 'works as DSL' do
      expect(taf_block.type).to eq(:Blg)
      expect(taf_block.properties).to eq({ test: 1, text: 'TAF is "great"' })
      expect(taf_block.children.count).to eq(1)
      expect(taf_block.children.first.type).to eq(:Bk)
      expect(taf_block.children.first.properties).to eq({ test: 2 })
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

  context '::convert' do
    describe 'Accounting::JournalEntry' do
      subject(:converted) { described_class.convert(conversion_subject) }
      let(:conversion_subject) do
        Accounting::JournalEntry.new(cost_account_id: 1050, amount_netto: 2091.75, date: Date.new(2024, 10, 5),
                                     text: "Lorem ipsum\nSecond Line, but its longer than sixty \"chars\", so nope!")
      end

      it 'converts correctly' do
        is_expected.to be_a described_class
        expect(converted.to_s).to eq(<<~TAF.chomp)
          {Bk
            BType=1
            CAcc=1050
            Date=05.10.2024
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
