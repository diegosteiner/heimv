# frozen_string_literal: true

# == Schema Information
#
# Table name: markdown_templates
#
#  id              :bigint           not null, primary key
#  body_i18n       :jsonb
#  key             :string
#  title_i18n      :jsonb
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  home_id         :bigint
#  organisation_id :bigint           not null
#
# Indexes
#
#  index_markdown_templates_on_home_id                              (home_id)
#  index_markdown_templates_on_key_and_home_id_and_organisation_id  (key,home_id,organisation_id) UNIQUE
#  index_markdown_templates_on_organisation_id                      (organisation_id)
#
# Foreign Keys
#
#  fk_rails_...  (home_id => homes.id)
#  fk_rails_...  (organisation_id => organisations.id)
#

require 'rails_helper'

RSpec.describe MarkdownTemplate, type: :model do
  describe 'by_key' do
    let(:key) { template.key }
    let(:template) { create(:markdown_template, key: 'test123') }
    let(:organisation) { template.organisation }

    it do
      expect(organisation.markdown_templates.by_key(key)).to eq(template)
    end
  end

  describe '::replace_in_template' do
    let!(:templates) do
      create_list(:markdown_template, 5, body_en: '# This is a template {{ test }} Footer', title_en: 'test')
    end

    it 'replaces all occurences' do
      MarkdownTemplate.replace_in_template!('test', 'success')
      templates.each do |markdown_template|
        markdown_template.reload
        expect(markdown_template.body_en).to eq('# This is a template {{ success }} Footer')
        expect(markdown_template.title_en).to eq('success')
      end
    end
  end
end
