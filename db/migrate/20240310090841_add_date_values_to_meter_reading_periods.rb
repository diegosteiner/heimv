class AddDateValuesToMeterReadingPeriods < ActiveRecord::Migration[7.1]
  def up
    MeterReadingPeriod.where.not(usage: nil).find_each do |meter_reading_period|
      usage = meter_reading_period.usage
      usage.tarif.before_usage_save(usage)
      usage.save!
    end
  end

  def down
  end
end
