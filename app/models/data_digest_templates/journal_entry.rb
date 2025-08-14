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

module DataDigestTemplates
  class JournalEntry < Tabular
    ::DataDigestTemplate.register_subtype self

    DEFAULT_COLUMN_CONFIG = [
      {
        header: ::JournalEntryBatch.human_attribute_name(:date),
        body: '{{ journal_entry.journal_entry_batch.date | date_format }}'
      },
      {
        header: ::JournalEntryBatch.model_name.human,
        body: '{{ journal_entry.journal_entry_batch_id }}'
      },
      {
        header: ::JournalEntryBatch.human_attribute_name(:trigger),
        body: '{{ journal_entry.journal_entry_batch.trigger }}'
      },
      {
        header: ::JournalEntryBatch.human_attribute_name(:text),
        body: '{{ journal_entry.text }}'
      },
      {
        header: ::JournalEntryBatch::Entry.human_attribute_name(:soll_account),
        body: '{{ journal_entry.soll_account }}'
      },
      {
        header: ::JournalEntryBatch::Entry.human_attribute_name(:haben_account),
        body: '{{ journal_entry.haben_account }}'
      },
      {
        header: ::JournalEntryBatch.human_attribute_name(:amount),
        body: '{{ journal_entry.amount | round: 2 }}'
      },
      {
        header: ::VatCategory.human_attribute_name(:accounting_vat_code),
        body: '{{ journal_entry.vat_category.accounting_vat_code }}'
      },
      {
        header: ::JournalEntryBatch::Entry.human_attribute_name(:vat_amount),
        body: '{{ journal_entry.vat_amount | round: 2 }}'
      },
      {
        header: ::JournalEntryBatch::Entry.human_attribute_name(:cost_center),
        body: '{{ journal_entry.cost_center }}'
      },
      {
        header: ::Booking.human_attribute_name(:ref),
        body: '{{ booking.ref }}'
      }
    ].freeze

    column_type :default do
      body do |journal_entry, template_context_cache|
        booking = journal_entry.parent.booking
        context = template_context_cache[cache_key(journal_entry.journal_entry_batch, journal_entry.hash)] ||=
          TemplateContext.new(booking:, organisation: booking.organisation, journal_entry:).to_h
        @templates[:body]&.render!(context)
      end
    end

    def crunch(records)
      record_ids = records.pluck(:id).uniq
      base_scope.where(id: record_ids).find_each(cursor: record_order.keys,
                                                 order: record_order.values).flat_map do |record|
        record.entries.map do |entry|
          template_context_cache = {}
          columns.map { |column| column.body(entry, template_context_cache) }
        end
      end
    end

    formatter(:taf) do |_options = {}|
      Export::Taf::Document.new do
        records.map { Export::Taf::Blocks::Batch.build_with_journal_entry_batch(it) }
      end.serialize
    end

    def periodfilter(period = nil)
      filter_class.new(date_after: period&.begin, date_before: period&.end)
    end

    def filter_class
      ::JournalEntryBatch::Filter
    end

    protected

    def base_scope
      @base_scope ||= ::JournalEntryBatch.joins(:booking).where(bookings: { organisation_id: organisation })
                                         .includes(booking: :organisation).ordered
    end
  end
end
