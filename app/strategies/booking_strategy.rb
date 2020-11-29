# frozen_string_literal: true

class BookingStrategy
  include TemplateRenderable
  include Translatable

  delegate :markdown_templates, to: :class

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
    def markdown_templates
      @markdown_templates ||= superclass.respond_to?(:markdown_templates) && superclass.markdown_templates || {}
    end

    def require_markdown_template(key, context = [])
      markdown_templates[key.to_sym] = MarkdownTemplate::Requirement.new(key, context)
    end
  end
end
