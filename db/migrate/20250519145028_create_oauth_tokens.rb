# frozen_string_literal: true

class CreateOAuthTokens < ActiveRecord::Migration[8.0]
  def change
    create_table :oauth_tokens do |t|
      t.references :organisation, null: false, foreign_key: true
      t.integer :audience, null: false
      t.string :access_token, null: true
      t.string :refresh_token, null: true
      t.string :token_type, null: true
      t.datetime :expires_at, null: true
      t.string :client_id, null: true
      t.string :client_secret, null: true
      t.string :authorize_url, null: true
      t.string :token_url, null: true

      t.timestamps
    end
  end
end
