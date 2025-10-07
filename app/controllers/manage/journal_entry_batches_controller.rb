# frozen_string_literal: true

module Manage
  class JournalEntryBatchesController < BaseController
    load_and_authorize_resource :journal_entry_batch
    before_action :set_filter, only: %i[index digest_and_process]

    def index
      @journal_entry_batches = @journal_entry_batches.of_organisation(current_organisation).ordered
      @journal_entry_batches = @filter.apply(@journal_entry_batches, cached: false) if @filter.any?
      @data_digest_templates = digestor.data_digest_templates
      respond_with :manage, @journal_entry_batches
    end

    def update
      @journal_entry_batch.update(journal_entry_batch_params)
      respond_with :manage, @journal_entry_batch, location: -> { manage_journal_entry_batches_path }
    end

    def destroy
      @journal_entry_batch.destroy
      respond_with :manage, @journal_entry_batch, location: -> { manage_journal_entry_batches_path }
    end

    def digest_and_process
      @journal_entry_batches = @journal_entry_batches.of_organisation(current_organisation).ordered
      @journal_entry_batches = @filter.apply(@journal_entry_batches, cached: false) if @filter.any?
      @data_digest = digestor.digest_and_process!(@journal_entry_batches,
                                                  data_digest_template_id: params[:data_digest_template_id],
                                                  period: (@filter.date_after)..(@filter.date_before))

      if @data_digest.persisted?
        redirect_to manage_data_digest_path(@data_digest)
      else
        redirect_to manage_journal_entry_batches_path(filter: @filter.attributes)
      end
    end

    private

    def digestor
      @digestor ||= JournalEntryBatchDigestor.new(current_organisation)
    end

    def set_filter
      default_filter_params = { processed: false }.with_indifferent_access
      @filter = JournalEntryBatch::Filter.new(default_filter_params.merge(journal_entry_batch_filter_params || {}))
    end

    def journal_entry_batch_params
      params.expect(journal_entry_batch: [:processed])
    end

    def journal_entry_batch_filter_params
      params[:filter]&.permit(%w[date_after date_before processed processed_at_before processed_at_after] +
        [{ triggers: [] }])
    end
  end
end
