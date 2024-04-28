# frozen_string_literal: true

require 'rails_helper'

describe Liquid do
  # subject(:action) { described_class.new(booking) }

  # let(:booking) { create(:booking, initial_state:, committed_request: false) }
  # let(:initial_state) { :provisional_request }

  describe '#render' do
    let(:template_string) { '' }
    subject(:template) { Liquid::Template.parse(template_string) }

    describe 'empty' do
      let(:template_string) { '{{ }}' }

      it { expect(template.render).to eq('') }
    end
  end
end
