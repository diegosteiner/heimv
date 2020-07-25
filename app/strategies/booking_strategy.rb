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
    []
  end

  def state_machine
    self.class::StateMachine
  end

  def displayed_booking_states; end

  def state_machine_automator
    self.class::StateMachineAutomator
  end

  def t(state, options = {})
    I18n.t(state, **options.merge(scope: i18n_scope + Array.wrap(options[:scope])))
  end

  def markdown_template_keys
    self.class::MARKDOWN_TEMPLATE_KEYS
  end
end
