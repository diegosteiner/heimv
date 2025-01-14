# frozen_string_literal: true

# == Schema Information
#
# Table name: bookings
#
#  id                     :uuid             not null, primary key
#  accept_conditions      :boolean          default(FALSE)
#  approximate_headcount  :integer
#  begins_at              :datetime
#  booking_flow_type      :string
#  booking_questions      :jsonb
#  booking_state_cache    :string           default("initial"), not null
#  cancellation_reason    :text
#  committed_request      :boolean
#  concluded              :boolean          default(FALSE)
#  conditions_accepted_at :datetime
#  editable               :boolean
#  email                  :string
#  ends_at                :datetime
#  ignore_conflicting     :boolean          default(FALSE), not null
#  import_data            :jsonb
#  internal_remarks       :text
#  invoice_address        :text
#  locale                 :string
#  notifications_enabled  :boolean          default(FALSE)
#  occupancy_color        :string
#  occupancy_type         :integer          default("free"), not null
#  purpose_description    :string
#  ref                    :string
#  remarks                :text
#  sequence_number        :integer
#  sequence_year          :integer
#  state_data             :json
#  tenant_organisation    :string
#  token                  :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  booking_category_id    :integer
#  home_id                :integer          not null
#  organisation_id        :bigint           not null
#  tenant_id              :integer
#

FactoryBot.define do
  factory :booking do
    organisation
    sequence(:email) { |n| "booking-#{n}@heimv.test" }
    sequence(:begins_at) { |i| (Time.zone.now + i.month).change(hour: 9, minute: 0) }
    ends_at { (begins_at + 1.week).change(hour: 14, minute: 0) }
    occupancy_type { Booking.occupancy_types[:free] }
    tenant_organisation { Faker::Company.name }
    committed_request { [true, false].sample }
    approximate_headcount { rand(1..30) }
    notifications_enabled { true }
    purpose_description { 'Pfadilager Test' }
    skip_infer_transitions { true }
    home { build(:home, organisation:) }
    transient do
      initial_state { nil }
      tenant { build(:tenant, organisation:, email:) }
    end

    after(:build) do |booking, evaluator|
      booking.tenant = evaluator.tenant if evaluator.tenant.present?
      booking.category ||= booking.organisation.booking_categories.sample
      booking.occupiables = [booking.home] if booking.occupancies.none?
    end

    before(:create) do |booking|
      booking.home.save!
    end

    after(:create) do |booking, evaluator|
      next if evaluator.initial_state.blank?

      Booking::StateTransition.initial_for(booking, evaluator.initial_state)
      booking.booking_flow.current_state(force_reload: true)
      booking.apply_transitions
    end

    trait :invoiced do
      transient do
        initial_state { :past }
        prepaid_amount { 0 }
        vat_category { nil }
      end
      after(:create) do |booking, evaluator|
        create_list(:tarif, 1, :with_accounting, organisation: booking.organisation,
                                                 vat_category: evaluator.vat_category)
        Usage::Factory.new(booking).build.each { _1.update(used_units: 48) }
        create(:payment, booking:, invoice: nil, amount: evaluator.prepaid_amount) if evaluator.prepaid_amount.present?
        invoice = Invoice::Factory.new(booking).build(issued_at: booking.ends_at)
        invoice.invoice_parts = InvoicePart::Factory.new(invoice).build
        invoice.save!
        invoice.recalculate!
        booking.reload
      end
    end
  end
end
