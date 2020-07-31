if defined?(Bullet)
  Bullet.enable = Rails.env.development? || Rails.env.test?
  Bullet.rails_logger = true
  Bullet.raise = true
  Bullet.add_whitelist type: :n_plus_one_query, class_name: 'Usage', association: :tarif
  Bullet.add_whitelist type: :n_plus_one_query, class_name: 'Tarifs::Amount', association: :tarif_selectors
  Bullet.add_whitelist type: :n_plus_one_query, class_name: 'Tarifs::Flat', association: :tarif_selectors
  Bullet.add_whitelist type: :n_plus_one_query, class_name: 'Tarifs::Metered', association: :tarif_selectors
  Bullet.add_whitelist type: :n_plus_one_query, class_name: 'Tarifs::OvernightStay', association: :tarif_selectors
  Bullet.add_whitelist type: :n_plus_one_query, class_name: 'Usage', association: :meter_reading_period
  Bullet.unused_eager_loading_enable = false
end
