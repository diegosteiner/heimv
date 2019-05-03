require 'csv'

class BookingReport < ApplicationRecord
  include TemplateRenderable

  PDF_DEFAULT_OPTIONS = {}.freeze
  CSV_DEFAULT_OPTIONS = {
    col_sep: ';',
    write_headers: true,
    skip_blanks: true,
    force_quotes: true,
    encoding: 'utf-8'
  }.freeze

  def to_s
    self.class.to_s
  end

  def filter
    @filter ||= Booking::Filter.new(filter_params)
  end

  def bookings(bookings = Booking.all)
    @bookings ||= filter.reduce(bookings)
  end

  def formats
    [:csv, :pdf]
  end

  def to_pdf(options = PDF_DEFAULT_OPTIONS)
    Export::Pdf::BookingReport.new(self, options).build.render
  end

  def to_csv(options = CSV_DEFAULT_OPTIONS)
    CSV.generate(options) do |csv|
      csv << generate_tabular_header
      bookings.each do |booking|
        csv << generate_tabular_row(booking)
      end
      csv << generate_tabular_footer
    end
  end

  def to_tabular
    data = []
    data << generate_tabular_header
    bookings.each do |booking|
      data << generate_tabular_row(booking)
    end
    data << generate_tabular_footer
  end


  def generate_tabular_header
    [
      Booking.human_attribute_name(:ref), Home.human_attribute_name(:name),
      Occupancy.human_attribute_name(:begins_at), Occupancy.human_attribute_name(:begins_at),
      Tenant.human_attribute_name(:first_name), Tenant.human_attribute_name(:last_name),
      Tenant.human_attribute_name(:email), Tenant.human_attribute_name(:phone),
      Tenant.human_attribute_name(:zipcode), Tenant.human_attribute_name(:city), Tenant.human_attribute_name(:country),
      Booking.human_attribute_name(:purpose)
    ]
  end

  def generate_tabular_footer
    []
  end

  # rubocop:disable Metrics/AbcSize
  def generate_tabular_row(booking)
    [
      booking.ref, booking.home.name, booking.occupancy.begins_at.iso8601, booking.occupancy.begins_at.iso8601,
      booking.tenant.first_name, booking.tenant.last_name,
      booking.tenant.email, booking.tenant.phone,
      booking.tenant.zipcode, booking.tenant.city, booking.tenant.country,
      booking.purpose
    ]
  end
  # rubocop:enable Metrics/AbcSize
end
