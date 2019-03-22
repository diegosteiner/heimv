module Manage
  class BookingReportsController < BaseController
    load_and_authorize_resource :booking_report

    def index
      respond_with :manage, @booking_reports
    end

    def new
      @booking_report = BookingReport.new(booking_report_params)
      respond_with :manage, @booking_report
    end

    def show
      respond_to do |format|
        format.html
        format.csv  { send_data @booking_report.to_csv, filename: "#{@booking_report.label}.csv" }
      end
    end

    def edit
    end

    def update
      Rails.logger.debug booking_report_params
      @booking_report.update(booking_report_params)
      respond_with :manage, @booking_report, location: manage_booking_reports_path(@booking_report)
    end

    def create
      @booking_report.save
      respond_with :manage, @booking_report, location: manage_booking_reports_path(@booking_report)
    end

    private

    def booking_report_params
      BookingReportParams.permit(params[:booking_report] || params)
    end
  end
end
