# frozen_string_literal: true

module Manage
  class NotificationsController < BaseController
    load_and_authorize_resource :booking
    load_and_authorize_resource :notification, through: :booking, shallow: true
    before_action :set_booking, only: %i[show]

    def index
      @notifications = @notifications.joins(:booking).where(booking: { organisation: current_organisation })
                                     .order(created_at: :DESC)
      @notifications = @notifications.unsent if @booking.blank?
      respond_with :manage, @notifications
    end

    def show
      respond_with :manage, @notification
    end

    def edit
      respond_with :manage, @notification
    end

    def update
      @notification.update(notification_params)
      purge_attachments
      @notification.deliver if @notification.valid? && params[:deliver].present?
      respond_with :manage, @notification, location: -> { manage_notification_path(@notification) }
    end

    def destroy
      @notification.destroy
      respond_with :manage, @notification, location: -> { manage_booking_path(@notification.booking) }
    end

    private

    def set_booking
      @booking = @notification&.booking
    end

    def purge_attachments
      @notification.attachments.each do |attachment|
        attachment.purge if params.dig(:notification, :attachments, attachment.to_param, '_destroy') == '1'
      end
    end

    def notification_params
      NotificationParams.new(params[:notification]).permitted
    end
  end
end
