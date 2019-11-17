class BookingStrategy
  include TemplateRenderable
  include Translatable

  def public_actions
    []
  end

  def manage_actions
    []
  end

  def state_machine
    self.class::StateMachine
  end

  def checklist
    self.class::Checklist
  end

  def state_machine_automator
    self.class::StateMachineAutomator
  end

  def t(state, options = {})
    I18n.t(state, options.merge(scope: i18n_scope + Array.wrap(options[:scope])))
  end
end
