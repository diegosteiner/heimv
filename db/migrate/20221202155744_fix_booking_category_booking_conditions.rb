class FixBookingCategoryBookingConditions < ActiveRecord::Migration[7.0]
  def up
    BookingConditions::BookingCategory.find_each do |condition|
      next if condition.organisation.booking_categories.exists?(id: condition.distinction)
      
      booking_category = condition.organisation.booking_categories.find_by(key: condition.distinction).exists?
      condition.update!(distinction: booking_category.id)
    end
    Tarif.where.not(home_id: nil).find_each do |tarif|
      type = BookingConditions::Occupiable
      tarif.booking_conditions.find_or_create_by!(type: type.to_s, distinction: tarif.home_id, must_condition: true)
    end
  end

  def down; end
end
