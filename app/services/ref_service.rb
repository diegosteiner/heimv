class RefService
  def booking(booking)
    "#{booking.home.ref}#{booking.occupancy.begins_at.year}#{booking.occupancy.begins_at.month}_#{booking.id.last(3)}"
  end
end
