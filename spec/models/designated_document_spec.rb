# frozen_string_literal: true

# == Schema Information
#
# Table name: designated_documents
#
#  id                   :bigint           not null, primary key
#  designation          :integer
#  locale               :string
#  name                 :string
#  remarks              :text
#  send_with_contract   :boolean          default(FALSE), not null
#  send_with_last_infos :boolean          default(FALSE)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  home_id              :bigint
#  organisation_id      :bigint           not null
#
# Indexes
#
#  index_designated_documents_on_home_id          (home_id)
#  index_designated_documents_on_organisation_id  (organisation_id)
#
require 'rails_helper'

RSpec.describe DesignatedDocument, type: :model do
  let(:organisation) { create(:organisation) }
  let(:home) { create(:home, organisation: organisation) }
  let(:document) { build(:designated_document, organisation: organisation) }
  let(:file) { Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/designated_document.txt'), 'text/plain') }

  describe '#designation' do
    it 'is undesigneted by default' do
      expect(document.designation).to be_nil
    end

    it 'keeps its designation' do
      document.terms!
      expect(document).to be_terms
      expect(document.designation.to_sym).to eq(:terms)
    end
  end

  describe '#file' do
    it 'allows file to be attached' do
      expect(document.file.attach(io: file, filename: 'designated_document.txt')).to be_truthy
      expect(document.save).to be_truthy
      expect(document.file).to be_attached
    end
  end

  describe '::blobs' do
    subject(:blobs) { described_class.where(organisation: organisation).blobs }
    let(:documents) do
      create_list(:designated_document, 2, organisation: organisation)
    end

    it do
      documents
      is_expected.to include(documents.first.file.blob)
      is_expected.to include(documents.last.file.blob)
    end
  end

  describe '::locale' do
    subject(:with_locale) { described_class.with_locale(locale).where(organisation: organisation) }
    let(:locale) { :de }
    let(:documents) do
      {
        with_matching_locale: create(:designated_document, organisation: organisation, locale: :de),
        without_matching_locale: create(:designated_document, organisation: organisation, locale: :fr),
        without_locale: create(:designated_document, organisation: organisation, locale: nil)
      }
    end

    it do
      documents
      is_expected.to include(documents[:with_matching_locale])
      is_expected.to include(documents[:without_locale])
      is_expected.not_to include(documents[:without_matching_locale])
    end
  end

  describe '::in_context' do
    subject(:in_context) { described_class.in_context(context) }
    let(:other_home) { create(:home, organisation: organisation) }
    let(:other_organisation) { create(:organisation) }
    let(:documents) do
      {
        on_organisation: create(:designated_document, organisation: organisation),
        on_home: create(:designated_document, organisation: organisation),
        on_other_organisation: create(:designated_document, organisation: other_organisation),
        on_other_home: create(:designated_document, organisation: organisation, home: other_home)
      }
    end

    context 'with organisation' do
      let(:context) { organisation }

      it do
        documents
        is_expected.to include(documents[:on_organisation])
        is_expected.not_to include(documents[:on_other_home])
        is_expected.not_to include(documents[:on_other_organisation])
        is_expected.not_to include(documents[:on_other_home])
      end
    end

    context 'with home' do
      let(:context) { home }

      it do
        documents
        is_expected.to include(documents[:on_organisation])
        is_expected.to include(documents[:on_home])
        is_expected.not_to include(documents[:on_other_organisation])
        is_expected.not_to include(documents[:on_other_home])
      end
    end
  end
end
