class MigrateDefaultBeginsAtAndEndsAt < ActiveRecord::Migration[7.1]
  def up
    Organisation.find_each do |organisation|
      settings = organisation.settings
      settings.default_begins_at_time = convert(settings.begins_at_default_time)
      settings.default_ends_at_time = convert(settings.begins_at_default_time + settings.ends_at_default_time)
      organisation.save
    end
  end

  protected

  def convert(duration)
    return unless duration.is_a?(ActiveSupport::Duration)

    "%02d:%02d" % [duration.parts[:hours] || 0, duration.parts[:minutes] || 0]
  end
end
