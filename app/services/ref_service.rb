class RefService
  def booking(booking)
    "#{booking.home.ref}#{booking.occupancy.begins_at.year}#{booking.occupancy.begins_at.month}#{booking.id}"
  end
end
