# frozen_string_literal: true

module Manage
  class JournalEntryBatchesController < BaseController
    load_and_authorize_resource :journal_entry_batch
    before_action :set_filter, only: :index

    def index
      @journal_entry_batches = @journal_entry_batches.joins(invoice: :booking).ordered
                                                     .where(invoices: {
                                                              bookings: { organisation: current_organisation }
                                                            })
      @journal_entry_batches = @filter.apply(@journal_entry_batches, cached: false) if @filter.any?
      respond_with :manage, @journal_entry_batches
    end

    # def new
    #   respond_with :manage, @journal_entry_batch
    # end

    # def edit
    #   respond_with :manage, @journal_entry_batch
    # end

    # def create
    #   @journal_entry_batch.assign_attributes(journal_entry_batch_params)
    #   @journal_entry_batch.currency ||= current_organisation.currency
    #   @journal_entry_batch.save
    #   respond_with :manage, location: manage_journal_entry_batches_path
    # end

    def update
      @journal_entry_batch.update(journal_entry_batch_params)
      respond_with :manage, @journal_entry_batch, location: manage_journal_entry_batches_path
    end

    # def update_many
    #   @tarifs = Tarif.where(organisation: current_organisation)
    #   @updated_tarifs = (tarifs_params[:tarifs]&.values || []).map do |tarif_params|
    #     @tarifs.find_by(id: tarif_params[:id])&.tap do |tarif|
    #       tarif.update(tarif_params)
    #     end
    #   end
    #   respond_with :manage, @updated_tarifs, location: manage_tarifs_path
    # end

    def destroy
      @journal_entry_batch.destroy
      respond_with :manage, @journal_entry_batch, location: manage_journal_entry_batches_path
    end

    def process_all
      @journal_entry_batches.unprocessed.update_all(processed_at: Time.zone.now) # rubocop:disable Rails/SkipsModelValidations
      redirect_to manage_journal_entry_batches_path
    end

    private

    def set_filter
      default_filter_params = { processed: false }.with_indifferent_access
      @filter = JournalEntryBatch::Filter.new(default_filter_params.merge(journal_entry_batch_filter_params || {}))
    end

    def journal_entry_batch_params
      params.expect(journal_entry_batch: [:processed])
    end

    def journal_entry_batch_filter_params
      params[:filter]&.permit(%w[date_after date_before processed processed_before processed_after] +
        [{ triggers: [] }])
    end
  end
end
