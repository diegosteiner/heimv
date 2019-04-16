class BookingStrategy
  include TemplateRenderable
  include Translatable

  def public_actions
    @public_actions ||= ActionCollection.new
  end

  def manage_actions
    @manage_actions ||= ActionCollection.new
  end

  def required_markdown_templates
    self.class::REQUIRED_MARKDOWN_TEMPLATES
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

  def state_machine_automator
    self.class::StateMachineAutomator
  end
end
