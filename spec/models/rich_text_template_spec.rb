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
# Indexes
#
#  index_rich_text_templates_on_key_and_organisation_id  (key,organisation_id) UNIQUE
#  index_rich_text_templates_on_organisation_id          (organisation_id)
#  index_rich_text_templates_on_type                     (type)
#
# Foreign Keys
#
#  fk_rails_...  (organisation_id => organisations.id)
#

require 'rails_helper'

RSpec.describe RichTextTemplate, type: :model do
  before do
    allow(RichTextTemplate).to receive(:template_key_valid?).and_return(true)
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
    it 'adds key to list' do
      expect { RichTextTemplate.define(:test1) }.to change { RichTextTemplate.definitions.count }.by(1)
      definition = RichTextTemplate.definitions[:test1]
      expect(definition[:type]).to(eq(RichTextTemplate))
      expect(definition[:key]).to(eq(:test1))
    end

    after { RichTextTemplate.definitions.delete(:test1) }
  end

  describe '#use' do
    let(:key) { :test2 }
    let(:rich_text_template) { create(:rich_text_template, key:) }
    let(:booking) { create(:booking, organisation: rich_text_template.organisation) }
    let(:context) { { booking: } }
    subject { rich_text_template.use(**context) }

    before { RichTextTemplate.define(key, context: %i[booking]) }
    after { RichTextTemplate.definitions.delete(key) }

    context 'with context' do
      it { is_expected.to be_a RichTextTemplate::InterpolationResult }
    end

    context 'with missing context' do
      let(:context) { { nonexistant: booking } }
      it { expect { subject }.to raise_error(RichTextTemplate::InvalidContext) }
    end
  end

  describe '#interpolate' do
    let(:title) { '' }
    let(:body) { '' }
    let(:rich_text_template) { build(:rich_text_template, body:, title:) }
    let(:context) { { booking: create(:booking, initial_state: :open_request) } }
    subject(:interpolate) { rich_text_template.interpolate(context) }

    context 'with booking_condition filter', pending: true do
      let(:body) do
        <<~BODY
          {% assign is_open_request = booking | booking_condition: "BookingState", "=", "open_request" %}
          {% if is_open_request %}Nice!{% else %}Bummer{% endif %}
        BODY
      end

      it { expect(interpolate.body.strip).to eq('Nice!') }
    end
  end
end
