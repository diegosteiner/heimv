# frozen_string_literal: true

module Manage
  class DataDigestsController < BaseController
    load_and_authorize_resource :data_digest
    helper_method :data_digest_templates

    def index
      @data_digests = @data_digests.where(organisation: current_organisation).order(created_at: :ASC)
      respond_with :manage, @data_digests.order(created_at: :ASC)
    end

    def show
      respond_to do |format|
        format.html
        format.csv { send_format_data(:csv) }
        format.pdf { send_format_data(:pdf) }
        format.taf { send_format_data(:taf, type: 'text/plain; charset=iso-8859-1; header=present') }
      end
    rescue Prawn::Errors::CannotFit
      redirect_to manage_data_digests_path, alert: t('.pdf_error')
    end

    def new
      @data_digest = DataDigest.new(data_digest_params)
      respond_with :manage, @data_digest
    end

    def create
      @data_digest.organisation = current_organisation
      @data_digest.save && CrunchDataDigestJob.perform_later(@data_digest.id)
      respond_with :manage, @data_digest, location: manage_data_digests_path, notice: t('.job_started')
    end

    def destroy
      @data_digest.destroy
      respond_with :manage, @data_digest, location: manage_data_digests_path
    end

    private

    def send_format_data(format, **)
      send_data @data_digest.format(format), filename: "#{@data_digest.label}.#{format}", **
    end

    def data_digest_templates
      @data_digest_templates ||= DataDigestTemplate.accessible_by(current_ability)
                                                   .where(organisation: current_organisation)
    end

    def data_digest_params
      params[:data_digest]&.permit(:data_digest_template_id, :period_from, :period_to, :period)
    end
  end
end
