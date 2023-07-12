class MigrateBookingConditions < ActiveRecord::Migration[7.0]
  TYPE_MIGRATIONS = [

  ]

  def up
    migrate_booking_attribute_conditions
    migrate_operators
  end

  protected

  def migrate_booking_attribute_conditions
    BookingCondition.where(type: 'BookingConditions::BookingApproximateHeadcountPerNight')
      .update_all(type: 'BookingConditions::BookingAttribute', compare_attribute: :approximate_headcount)
    BookingCondition.where(type: 'BookingConditions::BookingNights')
      .update_all(type: 'BookingConditions::BookingAttribute', compare_attribute: :nights)
    BookingCondition.where(type: 'BookingConditions::OvernightStays')
      .update_all(type: 'BookingConditions::BookingAttribute', compare_attribute: :overnight_stays)
  end

  def migrate_operators
    regex_string = "\\A(=|<=|<|>=|>|=)"
    regex = Regexp.new(regex_string)
    conditions = BookingCondition.where(BookingCondition.arel_table[:compare_value].matches_regexp(regex_string))
    conditions.find_each do |condition|
      match_data = regex.match(condition.compare_value)
      operator = match_data&.captures&.first
      condition.update!(compare_value: condition.compare_value&.gsub(regex), 
                        compare_operator: condition.classcompare_operators.keys.include?(operator) ? operator : nil)

    rescue 
      binding.pry
    end
  end
end
