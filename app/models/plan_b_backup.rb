# frozen_string_literal: true

# == Schema Information
#
# Table name: plan_b_backups
#
#  id              :bigint           not null, primary key
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  organisation_id :bigint           not null
#
# Indexes
#
#  index_plan_b_backups_on_organisation_id  (organisation_id)
#
# Foreign Keys
#
#  fk_rails_...  (organisation_id => organisations.id)
#
require 'zip'

# rubocop:disable Metrics/ClassLength
class PlanBBackup < ApplicationRecord
  BOOKING_COLUMNS_CONFIG = [
    {
      header: ::Booking.human_attribute_name(:id),
      body: '{{ booking.id }}'
    },
    {
      header: ::Booking.human_attribute_name(:ref),
      body: '{{ booking.ref }}'
    },
    {
      header: ::Home.model_name.human,
      body: '{{ booking.home.name }}'
    },
    {
      header: ::Occupiable.model_name.human(count: 2),
      body: '{{ booking.occupiable_ids | join: ", " }}'
    },
    {
      header: ::Booking.human_attribute_name(:begins_at),
      body: '{{ booking.begins_at | datetime_format }}'
    },
    {
      header: ::Booking.human_attribute_name(:ends_at),
      body: '{{ booking.ends_at | datetime_format }}'
    },
    {
      header: ::Booking.human_attribute_name(:state),
      body: '{{ booking.current_state }}'
    },
    {
      header: ::Booking.human_attribute_name(:purpose_description),
      body: "{{ booking.purpose_description }}\n{{ booking.category.title }}"
    },
    {
      header: ::Booking.human_attribute_name(:nights),
      body: '{{ booking.nights }}'
    },
    {
      header: ::Booking.human_attribute_name(:locale),
      body: '{{ booking.locale }}'
    },
    {
      header: ::Booking.human_attribute_name(:remarks),
      body: '{{ booking.remarks }}'
    },
    {
      header: ::Booking.human_attribute_name(:internal_remarks),
      body: '{{ booking.internal_remarks }}'
    },
    {
      header: ::Booking.human_attribute_name(:tenant_id),
      body: '{{ booking.tenant_id }}'
    },
    {
      header: ::Tenant.model_name.human,
      body: "{{ booking.tenant.full_name }}\n{{ booking.tenant_organisation }}"
    },
    {
      header: ::Tenant.human_attribute_name(:address),
      body: "{{ booking.tenant.address_lines | join: \"\n\" }}"
    },
    {
      header: ::Tenant.human_attribute_name(:email),
      body: '{{ booking.tenant.email }}'
    },
    {
      header: ::Tenant.human_attribute_name(:phone),
      body: '{{ booking.tenant.phone }}'
    }
  ].freeze
  belongs_to :organisation
  has_one_attached :zip

  before_save :generatate_zip

  protected

  def bookings_data_digest_template
    DataDigestTemplates::Booking.new(organisation: organisation, columns_config: BOOKING_COLUMNS_CONFIG,
                                     label: DataDigestTemplates::Booking.model_name.human)
  end

  def tenant_data_digest_template
    DataDigestTemplates::Tenant.new(organisation: organisation,
                                    label: DataDigestTemplates::Tenant.model_name.human)
  end

  def invoices_data_digest_template
    DataDigestTemplates::Invoice.new(organisation: organisation,
                                     label: DataDigestTemplates::Invoice.model_name.human)
  end

  def data_digests
    [
      bookings_data_digest_template.digest(:last_and_next_12_months),
      tenant_data_digest_template.digest(:ever),
      invoices_data_digest_template.digest(:last_and_next_12_months)
    ]
  end

  def data_digest_csv_zip
    Zip::OutputStream.write_buffer do |zip|
      data_digests.each.with_index(1) do |digest, _index|
        zip.put_next_entry("#{digest.label}.csv")
        zip.write(digest.format(:csv))
      end
    end.tap(&:rewind)
  end

  def generatate_zip
    I18n.with_locale(organisation.locale || I18n.locale) do
      self.zip = {
        io: data_digest_csv_zip,
        filename: filename,
        content_type: 'application/zip'
      }
    end
  end

  def filename
    "#{self.class.model_name.human}_#{Time.zone.today}_#{organisation}.zip"
  end
end
# rubocop:enable Metrics/ClassLength
