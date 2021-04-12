# frozen_string_literal: true

class BookingFlow
  include TemplateRenderable
  include Translatable

  delegate :rich_text_templates, to: :class

  def public_actions
    []
  end

  def manage_actions
    []
  end

  def booking_states
    state_machine_class.state_classes
  end

  def state_machine_class
    self.class::StateMachine
  end

  def displayed_booking_states; end

  class << self
    def rich_text_templates
      @rich_text_templates ||= superclass.respond_to?(:rich_text_templates) && superclass.rich_text_templates || {}
    end

    def require_rich_text_template(key, context = [])
      rich_text_templates[key.to_sym] = RichTextTemplate::Requirement.new(key, context)
    end
  end
end
