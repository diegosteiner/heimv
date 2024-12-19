# frozen_string_literal: true

module Manage
  class JournalEntriesController < BaseController
    load_and_authorize_resource :journal_entry

    def index
      @journal_entries = @journal_entries.joins(invoice: :booking).ordered
                                         .where(invoices: { bookings: { organisation: current_organisation } })
      respond_with :manage, @journal_entries
    end

    def new
      respond_with :manage, @journal_entry
    end

    def edit
      respond_with :manage, @journal_entry
    end

    def create
      @journal_entry.assign_attributes(journal_entry_params)
      @journal_entry.currency ||= current_organisation.currency
      @journal_entry.save
      respond_with :manage, location: manage_journal_entries_path
    end

    def update
      @journal_entry.update(journal_entry_params)
      respond_with :manage, location: manage_journal_entries_path
    end

    def destroy
      @journal_entry.destroy
      respond_with :manage, @journal_entry, location: manage_journal_entries_path
    end

    private

    def journal_entry_params
      params.require(:journal_entry).permit(*%i[invoice_id source_type source_id vat_category_id account_nr side amount
                                                date text currency ordinal source_document_ref book_type])
    end
  end
end
