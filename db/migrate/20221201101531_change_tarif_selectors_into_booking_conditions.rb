class ChangeTarifSelectorsIntoBookingConditions < ActiveRecord::Migration[7.0]
  TYPE_MAPPING = { "TarifSelectors::AlwaysApply" => "BookingConditions::AlwaysApply",
  "TarifSelectors::BookableExtra" => "BookingConditions::BookableExtra",
  "TarifSelectors::BookingApproximateHeadcountPerNight" => "BookingConditions::BookingApproximateHeadcountPerNight",
  "TarifSelectors::BookingCategory" => "BookingConditions::BookingCategory",
  "TarifSelectors::BookingNights" => "BookingConditions::BookingNights",
  "TarifSelectors::BookingOvernightStays" => "BookingConditions::BookingOvernightStays",
  "TarifSelectors::OccupancyDuration" => "BookingConditions::OccupancyDuration",
  "TarifSelectors::TenantOrganisation" => "BookingConditions::TenantOrganisation"
  }.freeze

  def change
    remove_index :tarif_selectors, column: :tarif_id, name: "index_tarif_selectors_on_tarif_id"
    rename_table :tarif_selectors, :booking_conditions
    rename_column :booking_conditions, :veto, :must_condition
    rename_column :booking_conditions, :tarif_id, :qualifiable_id
    add_column :booking_conditions, :qualifiable_type, :string, default: Tarif.to_s
    add_reference :booking_conditions, :organisation, null: true, foreign_key: true
    add_index :booking_conditions, [:qualifiable_id, :qualifiable_type]

    reversible do |direction|
      direction.up do 
        TYPE_MAPPING.each do |type_was, type_is|
          BookingCondition.where(type: type_was).update_all(type: type_is)
        end
        BookingCondition.find_each do |booking_condition|
          booking_condition.update(organisation: booking_condition.qualifiable.organisation)
        end
      end
    end

    change_column_default :booking_conditions, :qualifiable_type, from: Tarif.to_s, to: nil
    change_column_null :booking_conditions, :organisation_id, from: false, to: true
  end
end
