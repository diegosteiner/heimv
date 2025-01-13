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
#  send_with_accepted   :boolean          default(FALSE), not null
#  send_with_contract   :boolean          default(FALSE), not null
#  send_with_last_infos :boolean          default(FALSE)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  organisation_id      :bigint           not null
#
FactoryBot.define do
  factory :designated_document, aliases: [:document] do
    designation { nil }
    locale { nil }
    organisation
    file { Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/designated_document.txt'), 'text/plain') }
  end
end
