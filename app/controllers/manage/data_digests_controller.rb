# frozen_string_literal: true

module Manage
  class DataDigestsController < BaseController
    load_and_authorize_resource :data_digest

    def index
      @data_digests = @data_digests.where(organisation: current_organisation).order(type: :ASC)
      respond_with :manage, @data_digests.order(created_at: :ASC)
    end

    def new
      @data_digest = DataDigest.new(data_digest_params)
      @data_digest.organisation = current_organisation
      respond_with :manage, @data_digest
    end

    def show
      @periods = @data_digest.class.periods
    end

    def digest
      @periodic_data = @data_digest.digest(period)

      respond_to do |format|
        format.html
        format.csv { send_data @periodic_data.format(:csv), filename: "#{@data_digest.label}.csv" }
        format.pdf { send_data @periodic_data.format(:pdf), filename: "#{@data_digest.label}.pdf" }
      end
    end

    def edit; end

    def update
      @data_digest.update(data_digest_params)
      respond_with :manage, @data_digest, location: manage_data_digests_path
    end

    def create
      @data_digest.organisation = current_organisation
      @data_digest.save
      respond_with :manage, @data_digest, location: manage_data_digests_path
    end

    def destroy
      @data_digest.destroy
      respond_with :manage, @data_digest, location: manage_data_digests_path
    end

    private

    def period
      period = @data_digest.period(params[:range])
      return period if period.present?

      from = params[:from]
      to = params[:to]
      Range.new(from && Time.zone.parse(from), to && Time.zone.parse(to))
    end

    def data_digest_params
      DataDigestParams.new(params[:data_digest] || params).permitted
    end
  end
end
