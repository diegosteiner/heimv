# frozen_string_literal: true

class OrganisationMailer < ApplicationMailer
  default from: -> { (@organisation.mail_from || @organisation.email) },
          reply_to: -> { @organisation.email },
          charset: 'UTF-8'

  before_action :set_organisation
  after_action :set_delivery_options

  protected

  def set_delivery_options
    mail.delivery_method.settings.merge!(@organisation.smtp_settings) if @organisation.smtp_settings.present?
  end

  # rubocop:disable Naming/MemoizedInstanceVariableName
  def set_organisation
    @organisation ||= params[:organisation]
  end
  # rubocop:enable Naming/MemoizedInstanceVariableName
end
