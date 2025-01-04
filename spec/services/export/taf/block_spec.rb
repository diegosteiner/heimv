# frozen_string_literal: true

require 'rails_helper'

describe Export::Taf::Block, type: :model do
  subject(:taf_block) do
    described_class.new(:Blg, [described_class.new(:Bk, test: 2)], text: 'TAF is "great"', test: 1)
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
end
