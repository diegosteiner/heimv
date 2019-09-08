module Manage
  class DataDigestsController < BaseController
    load_and_authorize_resource :data_digest

    def index
      respond_with :manage, @data_digests
    end

    def new
      @data_digest = DataDigest.new(data_digest_params)
      respond_with :manage, @data_digest
    end

    def show
      respond_to do |format|
        format.html
        format.csv { send_data @data_digest.to_csv, filename: "#{@data_digest.label}.csv" }
        format.pdf { send_data @data_digest.to_pdf, filename: "#{@data_digest.label}.pdf" }
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

    def data_digest_params
      DataDigestParams.permit(params[:data_digest] || params)
    end
  end
end
