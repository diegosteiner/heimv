# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Address do
  describe '#blank?' do
    context 'with country only' do
      subject(:address) { described_class.new(country_code: 'CH') }

      it { is_expected.to be_blank }
    end

    context 'with city and postalcode' do
      subject(:address) { described_class.new(city: Faker::Address.city, postalcode: Faker::Address.zip_code, country_code: 'CH') }

      it { is_expected.not_to be_blank }
    end
  end

  describe '::parse' do
    subject(:address) { described_class.parse(address_lines) }

    context 'with well formatted address' do
      let(:address_lines) do
        <<~ADDRESS
          Peter Muster
          Adresszusatz
          Teststrasse 22a
          8031 Bälzwil
        ADDRESS
      end

      it do
        expect(address.attributes.symbolize_keys).to include(recipient: 'Peter Muster', city: 'Bälzwil',
                                                             suffix: 'Adresszusatz', street: 'Teststrasse',
                                                             street_nr: '22a', postalcode: '8031', country_code: 'CH')
      end
    end

    context 'with not so well formatted address' do
      let(:address_lines) do
        <<~ADDRESS
          Peter Muster, Teststrasse 22a, 8031 Bälzwil
        ADDRESS
      end

      it do
        expect(address.attributes.symbolize_keys).to include(recipient: 'Peter Muster', city: 'Bälzwil',
                                                             street: 'Teststrasse', street_nr: '22a',
                                                             postalcode: '8031', country_code: 'CH')
      end
    end
  end
end
