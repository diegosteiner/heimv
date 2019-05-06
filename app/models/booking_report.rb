# == Schema Information
#
# Table name: booking_reports
#
#  id            :bigint           not null, primary key
#  type          :string
#  label         :string
#  filter_params :jsonb
#  report_params :jsonb
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

require 'csv'

class BookingReport < ApplicationRecord
  DEFAULT_FORMAT_OPTIONS = {
    pdf: {
      document_options: { page_layout: :landscape }
    },
    csv: {
      col_sep: ';',
      write_headers: true,
      skip_blanks: true,
      force_quotes: true,
      encoding: 'utf-8'
    }
  }.freeze

  def formats
    %i[csv pdf]
  end

  def filter
    @filter ||= Booking::Filter.new(filter_params)
  end

  def bookings(bookings = Booking.all)
    @bookings ||= filter.reduce(bookings)
  end

  def to_pdf(options = {})
    options = DEFAULT_FORMAT_OPTIONS[:pdf].merge(options)
    Export::Pdf::BookingReport.new(self, options).build.render
  end

  def to_csv(options = {})
    options = DEFAULT_FORMAT_OPTIONS[:csv].merge(options)
    CSV.generate(options) { |csv| to_tabular.each { |row| csv << row } }
  end

  def to_tabular
    data = []
    data << generate_tabular_header
    data += bookings.map { |booking| generate_tabular_row(booking) }
    data << generate_tabular_footer
  end

  protected

  def generate_tabular_header
    [
      Booking.human_attribute_name(:ref), Home.model_name.human,
      Occupancy.human_attribute_name(:begins_at), Occupancy.human_attribute_name(:ends_at),
      Booking.human_attribute_name(:purpose)
    ]
  end

  def generate_tabular_footer
    []
  end

  def generate_tabular_row(booking)
    booking.instance_eval do
      [
        ref, home.name, I18n.l(occupancy.begins_at, format: :short), I18n.l(occupancy.begins_at, format: :short),
        Booking.human_enum(:purpose, purpose)
      ]
    end
  end
end
