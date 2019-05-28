module Manage
  class ReportsController < BaseController
    load_and_authorize_resource :report

    def index
      respond_with :manage, @reports
    end

    def new
      @report = Report.new(report_params)
      respond_with :manage, @report
    end

    def show
      respond_to do |format|
        format.html
        format.csv { send_data @report.to_csv, filename: "#{@report.label}.csv" }
        format.pdf { send_data @report.to_pdf, filename: "#{@report.label}.pdf" }
      end
    end

    def edit; end

    def update
      @report.update(report_params)
      respond_with :manage, @report, location: manage_reports_path
    end

    def create
      @report.save
      respond_with :manage, @report, location: manage_reports_path
    end

    def destroy
      @report.destroy
      respond_with :manage, @report, location: manage_reports_path
    end

    private

    def report_params
      ReportParams.permit(params[:report] || params)
    end
  end
end
