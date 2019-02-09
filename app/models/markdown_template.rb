class MarkdownTemplate < ApplicationRecord
  # TODO: remove state
  KEYS = %w[
    contract_text
    deposit_invoice_text
    invoice_invoice_text
    late_notice_invoice_text
    upcoming_message
    definitive_request_message
    overdue_request_message
    provisional_request_message
    confirmed_message
    open_request_message
    unconfirmed_request_message
    manage_new_booking_mail
    payment_overdue_message
  ].freeze

  validates :key, :locale, presence: true
  validates :key, uniqueness: true, inclusion: { in: KEYS }

  def to_markdown
    Markdown.new(body)
  end

  def interpolate(context)
    context = InterpolationContext.new(context) unless context.is_a?(InterpolationContext)
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

    def booking_purpose(input)
      i18n_translate(input, :'activerecord.enums.booking.purpose')
    end
  end
end
