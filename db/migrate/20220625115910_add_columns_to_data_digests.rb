class AddColumnsToDataDigests < ActiveRecord::Migration[7.0]
  def change
    add_column :data_digests, :columns_config, :jsonb, null: true

    reversible do |direction|
      direction.up do 
        normalize_types
        migrate_tarifs
      end
    end
  end

  private

  def normalize_types
    DataDigest.where(type: 'DataDigests::HomeBookingPlan').update_all(type: 'DataDigests::Booking')
    DataDigest.where(type: 'DataDigests::ParahotelerieStatistics').update_all(type: 'DataDigests::Booking')
    DataDigest.where(type: 'DataDigests::Tax').update_all(type: 'DataDigests::Booking')
    DataDigest.where(type: 'DataDigests::Tarif').update_all(type: 'DataDigests::Booking')
    DataDigest.where(type: 'DataDigests::Tenant').update_all(type: 'DataDigests::Booking')
    DataDigest.where(type: 'DataDigests::MeterReadingPeriod').update_all(type: 'DataDigests::Booking')
  end

  def migrate_tarifs 
    DataDigest.where.not(data_digest_params: nil).each do  |data_digest|
      tarif_ids = data_digest.data_digest_params['tarif_ids']
      next unless tarif_ids.present?

      data_digest.columns_config ||= data_digest.class::DEFAULT_COLUMN_CONFIG
      tarif_ids.each { |tarif_id| data_digest.columns_config += tarif_columns(::Tarif.find_by(id: tarif_id)) }
      data_digest.save
    end
  end

  def tarif_columns(tarif)
    return [] unless tarif

    [
      { 
        type: :usage, body: '{{ usage.used_units }}', tarif_id: tarif.id, 
        header: "#{tarif.label} (#{Usage.human_attribute_name(:used_units)}) ", 
      },
      { 
        type: :usage, body: '{{ usage.price | currency }}', tarif_id: tarif.id, 
        header: "#{tarif.label} (#{Usage.human_attribute_name(:price)})",  
      }
    ]
  end
end
