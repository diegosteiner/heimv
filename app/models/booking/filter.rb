class Booking
  class Filter < ApplicationFilter
    attribute :begins_at
    attribute :ends_at
    attribute :homes, default: []
    attribute :booking_states, default: []

    filter :begins_at, :ends_at do |params, bookings|
      occupancy_booking_ids = Occupancy.where(subject_type: :Booking)
                                       .at(params[:begins_at]..params[:ends_at])
                                       .pluck(:subject_id)
      bookings.where(id: occupancy_booking_ids)
    end

    filter :homes do |params, bookings|
      bookings.where(home_id: params[:homes])
    end

    filter :booking_states do |params, bookings|
      bookings.where(booking_state: params[:booking_states])
    end
  end
end
