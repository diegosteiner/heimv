module Manage
  module Homes
    class MeterReadingPeriodsController < BaseController
      load_and_authorize_resource :home
      load_and_authorize_resource :meter_reading_period, through: :home

      def index
        @meter_reading_period_groups = @meter_reading_periods.group_by(&:tarif)
        respond_with :manage, @home, @meter_reading_periods
      end

      # def show
      #   @meter_reading_period.tarif_meter_reading_periods.build
      #   respond_with :manage, @home, @meter_reading_period
      # end

      # def edit
      #   @meter_reading_period.tarif_meter_reading_periods.build
      #   respond_with :manage, @home, @meter_reading_period
      # end

      # def create
      #   @meter_reading_period.save
      #   respond_with :manage, @home, @meter_reading_period,
      #                location: edit_manage_home_meter_reading_period_path(@home, @meter_reading_period)
      # end

      # def update
      #   @meter_reading_period.update(meter_reading_period_params)
      #   respond_with :manage, @home, @meter_reading_period,
      #                location: edit_manage_home_meter_reading_period_path(@home, @meter_reading_period)
      # end

      # def destroy
      #   @meter_reading_period.destroy
      #   respond_with :manage, @home, @meter_reading_period,
      #                location: manage_home_meter_reading_periods_path(@home)
      # end

      # private

      # def meter_reading_period_params
      #   MeterReadingPeriodParams.new(params.require(:meter_reading_period))
      # end
    end
  end
end
