class RemoveHomeBookingCondtions < ActiveRecord::Migration[7.1]
  def up
    BookingCondition.where(type: 'BookingConditions::Occupiable').update_all({
      compare_attribute: :occupiable,
      compare_operator: :'='
    })
    BookingCondition.where(type: 'BookingConditions::Home').update_all({
      type: 'BookingConditions::Occupiable',
      compare_attribute: :home,
      compare_operator: :'='
    })
    BookingCondition.where(compare_operator: [nil, ''])
      .where.not(type: "BookingConditions::AlwaysApply")
      .update_all({ compare_operator: :'=' })
  end

  def down
  end
end
