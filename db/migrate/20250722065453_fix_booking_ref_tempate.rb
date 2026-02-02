# frozen_string_literal: true

class FixBookingRefTempate < ActiveRecord::Migration[8.0]
  def up
    change_column_default :organisations, :booking_ref_template,
                          from: '%<home_ref>s%<year>04d%<month>02d%<day>02d%<same_day_alpha>s',
                          to: '%<home_ref>s%<year>04d%<month>02d%<day>02d%<same_ref_alpha>s'

    Organisation.where(Organisation.arel_table[:booking_ref_template].matches('%<same_day_alpha>s%'))
                .find_each do |organisation|
      organisation.booking_ref_template.gsub!('<same_day_alpha>s', '<same_ref_alpha>s')
      organisation.save
    end
  end
end
