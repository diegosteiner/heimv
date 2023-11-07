# frozen_string_literal: true

# == Schema Information
#
# Table name: rich_text_templates
#
#  id              :bigint           not null, primary key
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
      expect(definition[:template_class]).to(eq(RichTextTemplate))
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
end
