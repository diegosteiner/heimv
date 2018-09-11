# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def self.human_enum(enum, value)
    return '-' if value.blank?

    I18n.t(value.demodulize.underscore, scope: [:activerecord, :enums, model_name.singular, enum])
  end
end
