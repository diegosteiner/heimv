class EnablePgcryptoExtension < ActiveRecord::Migration[5.0]
  def change
    enable_extension 'pgcrypto'
    enable_extension 'uuid-ossp'
  end
end