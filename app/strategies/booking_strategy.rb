# frozen_string_literal: true

class BookingStrategy
  include TemplateRenderable
  include Translatable

  def public_actions
    []
  end

  def manage_actions
    []
  end

  def booking_states
    state_machine.state_classes
  end

  def state_machine
    self.class::StateMachine
  end

  def displayed_booking_states; end

  # TODO: move to state class
  def t(state, options = {})
    I18n.t(state, **options.merge(scope: i18n_scope + Array.wrap(options[:scope])))
  end

  class << self
    def markdown_templates
      @markdown_templates ||= superclass.respond_to?(:markdown_templates) && superclass.markdown_templates || {}
    end

    def require_markdown_template(key, context = [])
      markdown_templates[key.to_sym] = MarkdownTemplate::Requirement.new(key, context)
    end

    def missing_markdown_templates(organisation)
      markdown_templates.keys.map(&:to_s) - organisation.markdown_templates.where(home_id: nil).pluck(:key)
    end
  end
end
