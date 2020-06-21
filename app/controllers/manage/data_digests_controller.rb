module Manage
  class DataDigestsController < BaseController
    load_and_authorize_resource :data_digest

    def index
      respond_with :manage, @data_digests.order(created_at: :ASC)
    end

    def new
      @data_digest = DataDigest.new(data_digest_params)
      @data_digest.organisation = current_organisation
      respond_with :manage, @data_digest
    end

    def show
      @periods = @data_digest.periods
    end

    def period
      @data_digest_period = @data_digest.periodic_data(data_digest_period_range)

      respond_to do |format|
        format.html
        format.csv { send_data @data_digest_period.format(:csv), filename: "#{@data_digest.label}.csv" }
        format.pdf { send_data @data_digest_period.format(:pdf), filename: "#{@data_digest.label}.pdf" }
      end
    end

    def edit; end

    def update
      @data_digest.update(data_digest_params)
      respond_with :manage, @data_digest, location: manage_data_digests_path
    end

    def create
      @data_digest.save
      respond_with :manage, @data_digest, location: manage_data_digests_path
    end

    def destroy
      @data_digest.destroy
      respond_with :manage, @data_digest, location: manage_data_digests_path
    end

    private

    def data_digest_period_range
      from = params[:from]
      to = params[:to]

      @data_digest.periods.fetch(
        params[:range]&.to_sym,
        Range.new(
          from && Time.zone.parse(from),
          to && Time.zone.parse(to)
        )
      )
    end

    def data_digest_params
      DataDigestParams.new(params[:data_digest] || params)
    end
  end
end
