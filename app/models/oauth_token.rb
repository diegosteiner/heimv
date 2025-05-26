# frozen_string_literal: true

# == Schema Information
#
# Table name: oauth_tokens
#
#  id              :bigint           not null, primary key
#  access_token    :string
#  audience        :integer          not null
#  authorize_url   :string
#  client_secret   :string
#  expires_at      :datetime
#  refresh_token   :string
#  token_type      :string
#  token_url       :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  client_id       :string
#  organisation_id :bigint           not null
#
require 'oauth2'

class OAuthToken < ApplicationRecord
  belongs_to :organisation

  enum :audience, { smtp: 1 }, prefix: true

  validates :audience, uniqueness: { scope: :organisation_id }

  def client
    @client ||= OAuth2::Client.new(client_id, client_secret, authorize_url:, token_url:)
  end

  def token
    @token ||= OAuth2::AccessToken.new(client, access_token, refresh_token:, expires_in:)
  end

  def refreshed_token
    return token unless token&.expired?

    @token = token.refresh!
    update(access_token: @token.token, refresh_token: @token.refresh_token,
           expires_at: @token.expires_in&.seconds&.from_now)
    @token
  end

  def expires_in
    (expires_at - Time.zone.now).seconds if expires_at.present?
  end
end
