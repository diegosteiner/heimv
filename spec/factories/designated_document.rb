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
FactoryBot.define do
  factory :designated_document do
    designation { 0 }
    locale { 'de' }
    # attached_to { nil }
  end
end
