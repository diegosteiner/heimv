# frozen_string_literal: true

module Manage
  class NotificationsController < BaseController
    load_and_authorize_resource :booking
    load_and_authorize_resource :notification, through: :booking, shallow: true
    before_action :set_booking, only: %i[show]

    def index
      @notifications = @notifications.order(created_at: :DESC)
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
      delete_attachments
      @notification.deliver if @notification.valid? && params[:deliver].present?
      respond_with :manage, @notification, location: manage_notification_path(@notification)
    end

    # def destroy
    #   @notification.destroy
    #   respond_with :manage, @notification, location: manage_booking_path(@notification.booking)
    # end

    private

    def set_booking
      @booking = @notification&.booking
    end

    def delete_attachments
      @notification.attachments.each do |attachment|
        attachment.purge if params.dig(:notification, :attachments, attachment.to_param, '_destroy') == '1'
      end
    end

    def notification_params
      NotificationParams.new(params[:notification]).permitted
    end
  end
end
