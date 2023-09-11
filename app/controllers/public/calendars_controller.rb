# frozen_string_literal: true

module Public
  class CalendarsController < BaseController
    load_and_authorize_resource :occupiable
    load_and_authorize_resource :occupancy, through: :occupiable
    layout false
    after_action :allow_embed, only: %i[embed]
    before_action :set_calendar, only: %i[index]
    respond_to :json, :ics

    def index
      respond_to do |format|
        format.json { render json: OccupancyCalendarSerializer.render(@calendar) }
        format.ics do
          render plain: IcalService.new.occupancies_to_ical(@calendar.occupancies,
                                                            include_tenant_details: include_tenant_details)
        end
      end
    end

    def embed; end

    def at
      date = parse_date(params[:date])
      occupancies = Occupancy.accessible_by(current_ability).merge(@occupiable.occupancies)
      manage = current_organisation_user.present? || current_user&.role_admin.presence
      redirect_to OccupancyAtService.new(@occupiable, occupancies).redirect_to(date, manage: manage)
    end

    private

    def include_tenant_details
      (current_organisation_user.present? || User.find_by_token(params[:token], current_organisation)) &&
        params[:include_tenant_details].present?
    end

    def parse_date(value, format: nil)
      return if value.blank?

      Date.parse(value, format: format)
    rescue Date::Error, TypeError
      nil
    end

    def set_calendar
      window_from = current_organisation_user.present? ? 2.months.ago : Time.zone.now.beginning_of_day

      @calendar = OccupancyCalendar.new(organisation: current_organisation, occupiables: @occupiable,
                                        window_from: window_from)
    end
  end
end
