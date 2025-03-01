# frozen_string_literal: true

module Manage
  class JournalEntriesController < BaseController
    load_and_authorize_resource :journal_entry
    before_action :set_filter, only: :index

    def index
      @journal_entries = @journal_entries.joins(invoice: :booking).ordered
                                         .where(invoices: { bookings: { organisation: current_organisation } })
      @journal_entries = @filter.apply(@journal_entries, cached: false) if @filter.any?
      respond_with :manage, @journal_entries
    end

    # def new
    #   respond_with :manage, @journal_entry
    # end

    # def edit
    #   respond_with :manage, @journal_entry
    # end

    # def create
    #   @journal_entry.assign_attributes(journal_entry_params)
    #   @journal_entry.currency ||= current_organisation.currency
    #   @journal_entry.save
    #   respond_with :manage, location: manage_journal_entries_path
    # end

    def update
      @journal_entry.update(journal_entry_params)
      respond_with :manage, @journal_entry, location: manage_journal_entries_path
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
      @journal_entry.destroy
      respond_with :manage, @journal_entry, location: manage_journal_entries_path
    end

    def process_all
      @journal_entries.unprocessed.update_all(processed_at: Time.zone.now) # rubocop:disable Rails/SkipsModelValidations
      redirect_to manage_journal_entries_path
    end

    private

    def set_filter
      default_filter_params = { processed: false }.with_indifferent_access
      @filter = JournalEntry::Filter.new(default_filter_params.merge(journal_entry_filter_params || {}))
    end

    def journal_entry_params
      params.expect(journal_entry: [:processed])
    end

    def journal_entry_filter_params
      params[:filter]&.permit(%w[date_after date_before processed processed_before processed_after triggers])
    end

    # def journal_entry_params
    #   params.require(:journal_entry).permit(*%i[invoice_id source_type source_id vat_category_id account_nr side
    #                                             amount date text currency ordinal ref book_type])
    # end
  end
end
