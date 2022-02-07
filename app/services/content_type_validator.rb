# frozen_string_literal: true

class ContentTypeValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if !value.attached? || content_types.include?(value.content_type)

    value.purge if record.new_record?
    record.errors.add(attribute, :content_type)
  end

  private

  def content_types
    options.fetch(:in)
  end
end
