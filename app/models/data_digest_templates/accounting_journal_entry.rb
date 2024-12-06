# frozen_string_literal: true

# == Schema Information
#
# Table name: data_digest_templates
#
#  id               :bigint           not null, primary key
#  columns_config   :jsonb
#  group            :string
#  label            :string
#  prefilter_params :jsonb
#  type             :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  organisation_id  :bigint           not null
#
# Indexes
#
#  index_data_digest_templates_on_organisation_id  (organisation_id)
#
# Foreign Keys
#
#  fk_rails_...  (organisation_id => organisations.id)
#

module DataDigestTemplates
  class AccountingJournalEntry < Tabular
    ::DataDigestTemplate.register_subtype self

    DEFAULT_COLUMN_CONFIG = [
      {
        header: ::Accounting::JournalEntry.human_attribute_name(:date),
        body: '{{ journal_entry.date | date_format }}'
      },
      {
        header: ::Accounting::JournalEntry.human_attribute_name(:reference),
        body: '{{ journal_entry.reference }}'
      },
      {
        header: ::Accounting::JournalEntry.human_attribute_name(:text),
        body: '{{ journal_entry.text }}'
      },
      {
        header: ::Accounting::JournalEntry.human_attribute_name(:soll_account),
        body: '{{ journal_entry.soll_account }}'
      },
      {
        header: ::Accounting::JournalEntry.human_attribute_name(:haben_account),
        body: '{{ journal_entry.haben_account }}'
      },
      {
        header: ::Accounting::JournalEntry.human_attribute_name(:amount),
        body: '{{ journal_entry.amount | round: 2 }}'
      },
      {
        header: ::Accounting::JournalEntry.human_attribute_name(:tax_code),
        body: '{{ journal_entry.tax_code }}'
      },
      {
        header: ::Accounting::JournalEntry.human_attribute_name(:cost_center),
        body: '{{ journal_entry.cost_center }}'
      },
      {
        header: ::Accounting::JournalEntry.model_name.human,
        body: '{{ journal_entry.to_s }}'
      },
      {
        header: ::Booking.human_attribute_name(:ref),
        body: '{{ booking.ref }}'
      }
    ].freeze

    column_type :default do
      body do |journal_entry, tempalte_context_cache|
        booking = journal_entry.booking
        context = tempalte_context_cache[cache_key(journal_entry)] ||=
          TemplateContext.new(booking:, organisation: booking.organisation, journal_entry:).to_h
        @templates[:body]&.render!(context)
      end
    end

    def records(period)
      invoice_filter = ::Invoice::Filter.new(issued_at_after: period&.begin, issued_at_before: period&.end)
      invoices = invoice_filter.apply(::Invoice.joins(:booking).where(bookings: { organisation: organisation }).kept)
      invoices.index_with(&:journal_entries)
    end

    def crunch(records)
      records.values.flatten.compact.map do |record|
        template_context_cache = {}
        columns.map { |column| column.body(record, template_context_cache) }
      end
    end

    formatter(:taf) do |_options = {}|
      records.keys.map do |source|
        TafBlock::Collection.new do
          derive(source.booking.tenant)
          derive(source)
        end
      end.join("\n\n")
    end

    protected

    def periodfilter(period = nil)
      raise NotImplementedError
      # filter_class.new(issued_at_after: period&.begin, issued_at_before: period&.end)
    end

    def base_scope
      raise NotImplementedError
      # @base_scope ||= ::Invoice.joins(:booking).where(bookings: { organisation_id: organisation }).kept
    end

    def prefilter
      raise NotImplementedError
    end
  end
end
