module Manage
  class MessagesController < BaseController
    load_and_authorize_resource :booking
    load_and_authorize_resource :message, through: :booking, shallow: true

    def index
      respond_with :manage, @messages
    end

    def new
      # @message.paid_at ||= Time.zone.now
      respond_with :manage, @message
    end

    def show
      respond_with :manage, @message
    end

    def edit
      respond_with :manage, @message
    end

    def create
      @message.save
      respond_with :manage, @message, location: manage_booking_messages_path(@booking)
    end

    def update
      @message.update(message_params)
      respond_with :manage, @message, location: manage_message_path(@message)
    end

    def destroy
      @message.destroy
      respond_with :manage, @message, location: manage_booking_path(@message.booking)
    end

    private

    def message_params
      MessageParams.permit(params[:message])
    end
  end
end
