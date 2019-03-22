require 'csv'

class BookingReport < ApplicationRecord
  include TemplateRenderable

  def to_s
    self.class.to_s
  end

  def filter
    @filter ||= Booking::Filter.new(filter_params)
  end

  def bookings(bookings = Booking.all)
    @bookings ||= filter.reduce(bookings)
  end

  def to_csv
    CSV.generate do |csv|
      csv << generate_csv_header
      bookings.each do |booking|
        csv << generate_csv_row(booking)
      end
    end
  end

  protected
  def generate_csv_header
    [
      Booking.human_attribute_name(:ref),
      Home.human_attribute_name(:name),
      Occupancy.human_attribute_name(:begins_at), Occupancy.human_attribute_name(:begins_at),
      Tenant.human_attribute_name(:first_name), Tenant.human_attribute_name(:last_name),
      Tenant.human_attribute_name(:email),
      Tenant.human_attribute_name(:zipcode), Tenant.human_attribute_name(:city), Tenant.human_attribute_name(:country),
      Booking.human_attribute_name(:purpose)
    ]
  end

  def generate_csv_row(booking)
    [
      booking.ref, booking.home.name, booking.occupancy.begins_at.iso8601, booking.occupancy.begins_at.iso8601,
      booking.tenant.first_name, booking.tenant.last_name, booking.tenant.email,
      booking.tenant.zipcode, booking.tenant.city, booking.tenant.country,
      booking.purpose
    ]
  end

end
