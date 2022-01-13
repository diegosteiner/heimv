# frozen_string_literal: true

# == Schema Information
#
# Table name: designated_documents
#
#  id               :bigint           not null, primary key
#  attached_to_type :string
#  designation      :integer          default(0)
#  locale           :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  attached_to_id   :bigint
#
# Indexes
#
#  index_designated_documents_on_attached_to  (attached_to_type,attached_to_id)
#
require 'rails_helper'

RSpec.describe DesignatedDocument, type: :model do
  let(:model) { build(:designated_document, attached_to: organisation, locale: :de) }
  let(:organisation) { build(:organisation) }
  let(:stub_file) { File.open(Rails.root.join('spec/fixtures/designated_document.txt')) }

  it 'is undesigneted by default' do
    expect(model).to be_undesignated
    expect(model.designation.to_sym).to eq(:undesignated)
  end

  it 'allows file to be attached' do
    model.file.attach(io: stub_file, filename: 'designated_document.txt')
    expect(model.save).to be_truthy
    expect(model.file).to be_attached
  end

  it 'can be attached to organisation' do
    expect(model.update(attached_to: organisation)).to be_truthy
  end

  describe 'scopes' do
    subject(:localized) { organisation.designated_documents.terms.localized(:de) }
    before do
      model.update(designation: :terms)
    end

    it 'can be found on organisation' do
      expect(localized.take).to be_a(DesignatedDocument)
      expect(organisation.designated_documents.build.tap do |document| 
        document.file.attach(io: stub_file, filename: 'designated_document.txt')
      end).to be_valid
    end
  end
end
