# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RichTextTemplateService, type: :model do
  subject(:service) { described_class.new(organisation) }

  let(:organisation) { create(:organisation) }

  before do
    allow(RichTextTemplate).to receive(:template_key_valid?).and_return(true)
  end

  describe '::replace_in_template' do
    let!(:templates) do
      create_list(:rich_text_template, 5, body_en: '# This is a template {{ test }} Footer', title_en: 'test',
                                          organisation:)
    end

    it 'replaces all occurences' do
      service.replace_in_template!('test', 'success')
      templates.each do |rich_text_template|
        rich_text_template.reload
        expect(rich_text_template.body_en).to eq('# This is a template {{ success }} Footer')
        expect(rich_text_template.title_en).to eq('success')
      end
    end
  end
end
