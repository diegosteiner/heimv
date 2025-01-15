# frozen_string_literal: true

require 'rails_helper'

describe Export::Taf::Document, type: :model do
  subject(:taf_document) do
    described_class.new do
      block(:Blg, text: 'TAF is "great"', test: 1) do
        block(:Bk, test: 2)
      end
    end
  end

  describe '#initialize' do
    subject(:taf_block) { taf_document.children.first }

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
    subject(:serialized) { taf_document.serialize.chomp }

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
end
