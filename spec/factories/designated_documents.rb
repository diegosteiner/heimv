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
FactoryBot.define do
  factory :designated_document do
    designation { 0 }
    locale { 'de' }
    organisation
    file { Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/designated_document.txt'), 'text/plain') }
  end
end
