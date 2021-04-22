# frozen_string_literal: true

# == Schema Information
#
# Table name: tarifs
#
#  id                       :bigint           not null, primary key
#  invoice_type             :string
#  label                    :string
#  meter                    :string
#  position                 :integer
#  prefill_usage_method     :string
#  price_per_unit           :decimal(, )
#  tarif_group              :string
#  tenant_visible           :boolean          default(TRUE)
#  transient                :boolean          default(FALSE)
#  type                     :string
#  unit                     :string
#  valid_from               :datetime
#  valid_until              :datetime
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  booking_copy_template_id :bigint
#  booking_id               :uuid
#  home_id                  :bigint
#
# Indexes
#
#  index_tarifs_on_booking_copy_template_id  (booking_copy_template_id)
#  index_tarifs_on_booking_id                (booking_id)
#  index_tarifs_on_home_id                   (home_id)
#  index_tarifs_on_type                      (type)
#

module Tarifs
  class Metered < Tarif
    module UsageDecorator
      extend ActiveSupport::Concern

      included do
        has_one :meter_reading_period, dependent: :nullify

        accepts_nested_attributes_for :meter_reading_period, reject_if: :all_blank

        before_save do
          self.used_units ||= meter_reading_period&.used_units
        end
      end

      def build_meter_reading_period(attrs = {})
        super(attrs).tap do |meter_reading_period|
          meter_reading_period.start_value ||= MeterReadingPeriod.where(tarif: tarif.original)
                                                                 .ordered&.last&.start_value
        end
      end
    end
  end
end
