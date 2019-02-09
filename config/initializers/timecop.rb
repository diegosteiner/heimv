if Rails.env.development?
  # Timecop.scale()
  new_time = Time.local(2019, 3, 15, 12, 0, 0)
  Timecop.travel(new_time)
end
