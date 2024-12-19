class BackFillSequenceNumbers < ActiveRecord::Migration[8.0]
  def up
    Organisation.find_each do |organisation|
      KeySequence.backfill_tenants(organisation, generate_ref: true)
      KeySequence.backfill_bookings(organisation, generate_ref: false)
      KeySequence.backfill_invoices(organisation, generate_ref: true)
    end
  end
end
