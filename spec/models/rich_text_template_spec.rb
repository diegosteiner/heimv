# frozen_string_literal: true

# == Schema Information
#
# Table name: rich_text_templates
#
#  id              :bigint           not null, primary key
#  autodeliver     :boolean          default(TRUE)
#  body_i18n       :jsonb
#  enabled         :boolean          default(TRUE)
#  key             :string
#  title_i18n      :jsonb
#  type            :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  organisation_id :bigint           not null
#

require 'rails_helper'

RSpec.describe RichTextTemplate do
  before do
    allow(described_class).to receive(:template_key_valid?).and_return(true)
  end

  describe 'by_key' do
    let(:key) { :test }
    let(:template) { create(:rich_text_template, key:) }
    let(:organisation) { template.organisation }

    it do
      expect(organisation.rich_text_templates.by_key(key)).to eq(template)
    end
  end

  describe '::define' do
    after { described_class.definitions.delete(:test1) }

    it 'adds key to list' do
      expect { described_class.define(:test1) }.to change { described_class.definitions.count }.by(1)
      definition = described_class.definitions[:test1]
      expect(definition[:type]).to(eq(described_class))
      expect(definition[:key]).to(eq(:test1))
    end
  end

  describe '#use' do
    subject(:use) { rich_text_template.use(**context) }

    let(:key) { :test2 }
    let(:rich_text_template) { create(:rich_text_template, key:) }
    let(:booking) { create(:booking, organisation: rich_text_template.organisation) }
    let(:context) { { booking: } }

    before { described_class.define(key, context: %i[booking]) }
    after { described_class.definitions.delete(key) }

    context 'with context' do
      it { is_expected.to be_a RichTextTemplate::InterpolationResult }
    end

    context 'with missing context' do
      let(:context) { { nonexistant: booking } }

      it { expect { use }.to raise_error(RichTextTemplate::InvalidContext) }
    end
  end

  describe '#interpolate' do
    subject(:interpolated) { rich_text_template.interpolate(context) }

    let(:title) { '' }
    let(:body) { '' }
    let(:rich_text_template) { build(:rich_text_template, body:, title:) }
    let(:context) { { booking: create(:booking, initial_state: :open_request) } }

    describe 'with specific locale' do
      subject(:interpolated) { rich_text_template.interpolate(context, locale: locale) }

      let(:rich_text_template) { build(:rich_text_template, body_i18n: { de: 'auf Deutsch', fr: 'en francais' }) }
      let(:locale) { :fr }

      it { expect(interpolated.body.strip).to eq('en francais') }
    end
  end

  describe '#load_locale_defaults' do
    subject(:load_locale_defaults) { rich_text_template.load_locale_defaults }

    let(:key) { :email_contract_notification }
    let(:not_default_text) { 'Not the default' }

    let(:rich_text_template) { build(:rich_text_template, key:, title: not_default_text, body: not_default_text) }

    it do
      expect(rich_text_template.body).to eq not_default_text
      expect(rich_text_template.title).to eq not_default_text
      load_locale_defaults
      expect(rich_text_template.save).to be_truthy
      expect(rich_text_template.title).not_to eq not_default_text
    end
  end

  describe '::defautls_for_key' do
    subject(:defaults) { described_class.defaults_for_key(key:) }

    let(:key) { :email_contract_notification }

    it do
      expect(defaults[:body_i18n][:de]).not_to be_blank
      expect(defaults[:title_i18n][:de]).not_to be_blank
    end
  end
end
