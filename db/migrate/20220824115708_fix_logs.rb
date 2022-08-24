class FixLogs < ActiveRecord::Migration[7.0]
  def up
    Booking::Log.find_each do |log|
      log.data['transitions'] = %w[open_request] if log.logged_transitions == ['BookingStates::OpenRequest']
      log.save
    end
  end
end
