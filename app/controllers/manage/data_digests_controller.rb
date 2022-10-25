# frozen_string_literal: true

module Manage
  class DataDigestsController < BaseController
    load_and_authorize_resource :data_digest

    def index
      @data_digests = @data_digests.where(organisation: current_organisation).order(created_at: :ASC)
      respond_with :manage, @data_digests.order(created_at: :ASC)
    end

    def new
      @data_digest_templates = DataDigestTemplate.accessible_by(current_ability)
                                                 .where(organisation: current_organisation)
      @data_digest = DataDigest.new(data_digest_params)
      respond_with :manage, @data_digest
    end

    def show
      respond_to do |format|
        format.html
        format.csv { send_data @data_digest.format(:csv), filename: "#{@data_digest.label}.csv" }
        # format.pdf { send_data @data_digest.format(:pdf), filename: "#{@data_digest.label}.pdf" }
      end
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

    def data_digest_params
      params[:data_digest]&.permit(:data_digest_template_id, :period_from, :period_to)
    end
  end
end
