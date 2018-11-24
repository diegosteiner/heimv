if Rails.env.development?
  # Timecop.scale()
  Timecop.travel(7.days.from_now)
end
