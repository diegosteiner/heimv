class AddBookingAgentModeToBookingQuestions < ActiveRecord::Migration[7.1]
  def change
    add_column :booking_questions, :booking_agent_mode, :integer, default: 0
    rename_column :booking_questions, :mode, :tenant_mode

    reversible do |direction|
      direction.up do
        BookingQuestion.where(tenant_mode: 1).update_all(tenant_mode: -1)
        BookingQuestion.where(tenant_mode: 0).update_all(tenant_mode: 1)
        BookingQuestion.where(tenant_mode: -1).update_all(tenant_mode: 0)
      end

      direction.down do
        BookingQuestion.where(tenant_mode: 1).update_all(tenant_mode: -1)
        BookingQuestion.where(tenant_mode: 0).update_all(tenant_mode: 1)
        BookingQuestion.where(tenant_mode: -1).update_all(tenant_mode: 0)
      end
    end
  end
end
