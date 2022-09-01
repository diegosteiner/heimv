# frozen_string_literal: true

# == Schema Information
#
# Table name: rich_text_templates
#
#  id                 :bigint           not null, primary key
#  body_i18n          :jsonb
#  body_i18n_markdown :jsonb
#  enabled            :boolean          default(TRUE)
#  key                :string
#  title_i18n         :jsonb
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  home_id            :bigint
#  organisation_id    :bigint           not null
#
# Indexes
#
#  index_rich_text_templates_on_home_id                        (home_id)
#  index_rich_text_templates_on_key_and_home_and_organisation  (key,home_id,organisation_id) UNIQUE
#  index_rich_text_templates_on_organisation_id                (organisation_id)
#
# Foreign Keys
#
#  fk_rails_...  (home_id => homes.id)
#  fk_rails_...  (organisation_id => organisations.id)
#

require 'rails_helper'

RSpec.describe RichTextTemplate, type: :model do
  before do
    allow(RichTextTemplate).to receive(:template_key_valid?).and_return(true)
  end

  describe 'by_key' do
    let(:key) { :test }
    let(:template) { create(:rich_text_template, key: key) }
    let(:organisation) { template.organisation }

    it do
      expect(organisation.rich_text_templates.by_key(key)).to eq(template)
    end
  end

  describe '::require_template' do
    it 'adds key to list' do
      expect { RichTextTemplate.require_template(:test1) }.to change { RichTextTemplate.required_templates.count }.by(1)
      expect(RichTextTemplate.required_templates.keys).to include(:test1)
    end
  end
end
