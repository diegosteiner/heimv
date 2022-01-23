# frozen_string_literal: true

# == Schema Information
#
# Table name: designated_documents
#
#  id              :bigint           not null, primary key
#  designation     :integer
#  locale          :string
#  remarks         :text
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  home_id         :bigint
#  organisation_id :bigint           not null
#
# Indexes
#
#  index_designated_documents_on_home_id                  (home_id)
#  index_designated_documents_on_organisation_id          (organisation_id)
#  index_designated_documentss_on_designation_and_locale  (designation,locale,home_id,organisation_id) UNIQUE
#
require 'rails_helper'

RSpec.describe DesignatedDocument, type: :model do
  let(:organisation) { create(:organisation) }
  let(:document) { build(:designated_document, organisation: organisation) }
  let(:file) { Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/designated_document.txt'), 'text/plain') }

  describe '#designation' do
    it 'is undesigneted by default' do
      expect(document).to be_undesignated
      expect(document.designation.to_sym).to eq(:undesignated)
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

  describe '#localized' do
    let(:specifically_localized_document) do
      create(:designated_document, organisation: organisation, designation: :terms, locale: :de)
    end
    let(:generally_localized_document) do
      create(:designated_document, organisation: organisation, designation: :terms, locale: nil)
    end
    before do
      specifically_localized_document
      generally_localized_document
    end

    context 'with existing locale' do
      it do
        expect(organisation.designated_documents.localized(:terms, locale: :de))
          .to eq(specifically_localized_document)
      end
      it do
        expect(organisation.designated_documents.localized(:terms, locale: :fr))
          .to eq(generally_localized_document)
      end
    end
  end
end
