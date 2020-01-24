module Manage
  class MessagesController < BaseController
    load_and_authorize_resource :booking
    load_and_authorize_resource :message, through: :booking, shallow: true
    before_action :set_booking, only: %i[show]

    def index
      @messages = @messages.order(created_at: :DESC)
      respond_with :manage, @messages
    end

    def show
      respond_with :manage, @message
    end

    # def new
    #   respond_with :manage, @message
    # end

    def edit
      respond_with :manage, @message
    end

    # def create
    #   @message.save
    #   respond_with :manage, @message, location: manage_booking_messages_path(@booking)
    # end

    def update
      @message.update(message_params)
      @message.deliver if @message.valid? && params[:deliver].present?
      respond_with :manage, @message, location: manage_message_path(@message)
    end

    # def destroy
    #   @message.destroy
    #   respond_with :manage, @message, location: manage_booking_path(@message.booking)
    # end

    private

    def set_booking
      @booking = @message&.booking
    end

    def message_params
      MessageParams.new(params[:message])
    end
  end
end
