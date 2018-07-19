# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def self.human_enum(enum, value)
    I18n.t(value, scope: [:activerecord, :enums, model_name.singular, enum])
  end
end
