class BookingStrategy
  include TemplateRenderable
  include Translatable

  def public_actions
    self.class::Actions::Public
  end

  def manage_actions
    self.class::Actions::Manage
  end

  def state_machine
    self.class::StateMachine
  end

  def checklist
    self.class::Checklist
  end

  def t(state, options = {})
    I18n.t(state, options.merge(scope: i18n_scope + Array.wrap(options[:scope])))
  end

  def booking_actions
    self.class::Actions
  end

  def state_machine_automator
    self.class::StateMachineAutomator
  end
end
