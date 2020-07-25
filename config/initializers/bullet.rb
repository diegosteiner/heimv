Bullet.enable = true
Bullet.rails_logger = true
Bullet.raise = Rails.env.development? || Rails.env.test?

# Exceptions
Bullet.add_whitelist type: :n_plus_one_query, class_name: 'Usage', association: :tarif
Bullet.unused_eager_loading_enable = false
