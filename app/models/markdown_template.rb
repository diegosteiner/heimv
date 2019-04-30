# == Schema Information
#
# Table name: markdown_templates
#
#  id         :bigint(8)        not null, primary key
#  key        :string
#  title      :string
#  locale     :string
#  body       :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class MarkdownTemplate < ApplicationRecord
  validates :key, :locale, presence: true
  validates :key, uniqueness: true

  def to_markdown
    Markdown.new(body)
  end

  def interpolate(context)
    liquid_template = Liquid::Template.parse(body)
    Markdown.new(liquid_template.render(context.to_liquid, [Filters]))
  end
  alias % interpolate

  def self.[](key, locale: I18n.locale)
    find_by(key: key, locale: locale) || new(key: key)
  end

  module Filters
    def i18n_translate(input, scope = nil)
      I18n.t(input, scope: scope, default: nil)
    end

    def i18n_localize(input, format = :short)
      I18n.l(input, format: format)
    end

    def booking_purpose(input)
      i18n_translate(input, :'activerecord.enums.booking.purpose')
    end
  end
end
