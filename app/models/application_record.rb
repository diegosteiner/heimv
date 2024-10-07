# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def self.human_enum(enum, value, default: '-', **)
    return default if value.blank?

    I18n.t(value.to_s.demodulize.underscore, scope: [:activerecord, :enums, model_name.singular, enum], **)
  end

  def self.human_model_name(...)
    model_name.human(...)
  end

  def self.locale_enum(name = :locale, prefix: true, default: nil)
    enum name, I18n.available_locales.index_by(&:to_sym).transform_values(&:to_s), prefix:, default:
  end
end
