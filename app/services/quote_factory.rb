# frozen_string_literal: true

class QuoteFactory
  RichTextTemplate.define(:quote_text, context: %i[booking quote])

  def initialize(booking)
    @booking = booking
  end

  def build(suggest_items: false, **attributes)
    Quote.new(defaults.merge(attributes)).tap do |quote|
      quote.text ||= text_from_template(quote)
      quote.items ||= []
      quote.items += Invoice::ItemFactory.new(quote).build if suggest_items
    end
  end

  def defaults
    {
      issued_at: Time.zone.today, booking: @booking, locale: @booking.locale || I18n.locale
    }
  end

  protected

  def text_from_template(quote)
    quote.organisation.rich_text_templates.enabled.by_key(:quote_text)
         &.interpolate(template_context(quote), locale: quote.locale)
         &.body
  end

  def template_context(quote)
    TemplateContext.new(
      quote:, invoice: quote, booking: @booking,
      costs: CostEstimation.new(@booking), organisation: @booking.organisation
    )
  end
end
