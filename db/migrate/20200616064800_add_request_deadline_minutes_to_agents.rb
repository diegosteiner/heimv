class AddRequestDeadlineMinutesToAgents < ActiveRecord::Migration[6.0]
  def change
    # Default: 10 days
    add_column :booking_agents, :request_deadline_minutes, :integer, default: 14400
  end
end
