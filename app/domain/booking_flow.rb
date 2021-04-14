# frozen_string_literal: true

class BookingFlow
  include TemplateRenderable
  include Translatable

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
end
