class RenameReportsToDataDigests < ActiveRecord::Migration[5.2]
  def up
    rename_table :reports, :data_digests

    DataDigest.where(type: "Reports::Tenant").update_all(type: "DataDigests::Tenant")
    DataDigest.where(type: "Reports::Tarif").update_all(type: "DataDigests::Tarif")
    DataDigest.where(type: "Reports::BookingReport").update_all(type: "DataDigests::Booking")
    DataDigest.where(type: "Reports::PaymentReport").update_all(type: "DataDigests::Payment")
  end

  def down
    DataDigest.where(type: "DataDigests::Tenant").update_all(type: "Reports::Tenant")
    DataDigest.where(type: "DataDigests::Tarif").update_all(type: "Reports::Tarif")
    DataDigest.where(type: "DataDigests::Booking").update_all(type: "Reports::BookingReport")
    DataDigest.where(type: "DataDigests::Payment").update_all(type: "Reports::PaymentReport")

    rename_table :data_digests, :reports
  end
end
