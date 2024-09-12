class RenameDateSpanBookingCondition  < ActiveRecord::Migration[7.2]
  def change
    BookingCondition.where(type: 'BookingConditions::DateSpan').update_all(type: 'BookingConditions::BookingDateTime')
    BookingConditions::BookingDateTime.find_each { |condition| update_condition(condition) }
  end

  protected

  def update_condition(condition)
    condition.instance_exec do
      (begin_compare_value, end_compare_value) = compare_value&.split('-')
      compare_attribute = :begins_at unless %w[begins_at ends_at now].include?(compare_attribute)

      dup.update!(compare_value: rewrite_compare_value.call(begin_compare_value),
                  compare_operator: :'>=',
                  compare_attribute: ) if begin_compare_value.present?

      dup.update!(compare_value: rewrite_compare_value.call(end_compare_value),
                  compare_operator: :'<=',
                  compare_attribute: ) if end_compare_value.present?

      destroy!
    end
  end

  def rewrite_compare_value(compare_value)
    date_parts = compare_value.split('.').map { '%02d' % _1.to_i }
    date_parts += ['*' * (3 - date_parts.count)]
    date_parts.compact_blank.reverse.join('-')
  end

end
