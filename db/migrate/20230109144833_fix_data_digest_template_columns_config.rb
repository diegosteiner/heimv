class FixDataDigestTemplateColumnsConfig < ActiveRecord::Migration[7.0]
  def change
    DataDigestTemplate.replace_in_columns_config!('booking.occupancy.begins_at', 'booking.begins_at')
    DataDigestTemplate.replace_in_columns_config!('booking.occupancy.ends_at', 'booking.ends_at')
    DataDigestTemplate.replace_in_columns_config!('booking.occupancy.occupancy_type', 'booking.occupancy_type')
    DataDigestTemplate.replace_in_columns_config!('booking.home.name', 'booking.homes | map: \"name\" | join: \", \"')
  end
end
