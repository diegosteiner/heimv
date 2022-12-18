class RemoveHomeIdFromOperatorResponsibilities < ActiveRecord::Migration[7.0]
  def change
    add_booking_conditions_for_operator_responsibilities

    remove_reference :operator_responsibilities, :home
  end

  protected

  def add_booking_conditions_for_operator_responsibilities
    OperatorResponsibility.where(booking: nil).find_each do |responsibility| 
      next if responsibility.home_id.blank?

      responsibility.assigning_conditions << BookingConditions::Occupiable.new(qualifiable: responsibility, 
                                                                               distinction: responsibility.home_id)
      responsibility.save
    end
  end
end
