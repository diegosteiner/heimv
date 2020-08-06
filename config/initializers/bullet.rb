# frozen_string_literal: true

if defined?(Bullet)
  Bullet.enable = Rails.env.development? || Rails.env.test?
  Bullet.alert = Rails.env.development?
  Bullet.rails_logger = true
  Bullet.raise = Rails.env.test?
  Bullet.add_whitelist type: :n_plus_one_query, class_name: 'Usage', association: :tarif
  Bullet.add_whitelist type: :n_plus_one_query, class_name: 'Tarifs::Amount', association: :tarif_selectors
  Bullet.add_whitelist type: :n_plus_one_query, class_name: 'Tarifs::Flat', association: :tarif_selectors
  Bullet.add_whitelist type: :n_plus_one_query, class_name: 'Tarifs::Metered', association: :tarif_selectors
  Bullet.add_whitelist type: :n_plus_one_query, class_name: 'Tarifs::OvernightStay', association: :tarif_selectors
  Bullet.add_whitelist type: :n_plus_one_query, class_name: 'Usage', association: :meter_reading_period
  Bullet.add_whitelist type: :n_plus_one_query, class_name: 'Usage', association: :organisation
  Bullet.unused_eager_loading_enable = false
end
