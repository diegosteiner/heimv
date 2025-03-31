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
        header: ::JournalEntry.human_attribute_name(:date),
        body: '{{ journal_entry_fragment.journal_entry.date | date_format }}'
      },
      {
        header: ::JournalEntry.human_attribute_name(:ref),
        body: '{{ journal_entry_fragment.journal_entry.ref }}'
      },
      {
        header: ::JournalEntry.human_attribute_name(:text),
        body: '{{ journal_entry_fragment.text }}'
      },
      {
        header: ::JournalEntry.human_attribute_name(:soll_account),
        body: '{{ journal_entry_fragment.soll_account }}'
      },
      {
        header: ::JournalEntry.human_attribute_name(:haben_account),
        body: '{{ journal_entry_fragment.haben_account }}'
      },
      {
        header: ::JournalEntry.human_attribute_name(:amount),
        body: '{{ journal_entry_fragment.amount | round: 2 }}'
      },
      {
        header: ::JournalEntry.human_attribute_name(:book_type),
        body: '{{ journal_entry_fragment.book_type }}'
      },
      {
        header: ::Booking.human_attribute_name(:ref),
        body: '{{ booking.ref }}'
      }
    ].freeze

    column_type :default do
      body do |journal_entry_fragment, template_context_cache|
        booking = journal_entry_fragment.parent.booking
        context = template_context_cache[cache_key(journal_entry_fragment)] ||=
          TemplateContext.new(booking:, organisation: booking.organisation, journal_entry_fragment:).to_h
        @templates[:body]&.render!(context)
      end
    end

    def crunch(records)
      record_ids = records.pluck(:id).uniq
      base_scope.where(id: record_ids).find_each(cursor: record_order.keys,
                                                 order: record_order.values).flat_map do |record|
        record.fragments.map do |fragment|
          template_context_cache = {}
          columns.map { |column| column.body(fragment, template_context_cache) }
        end
      end
    end

    formatter(:taf) do |_options = {}|
      journal_entries = records
      Export::Taf::Document.new do
        journal_entries.each { journal_entry(it) }
      end.serialize
    end

    def periodfilter(period = nil)
      filter_class.new(date_after: period&.begin, date_before: period&.end)
    end

    def filter_class
      ::JournalEntry::Filter
    end

    protected

    def base_scope
      @base_scope ||= ::JournalEntry.joins(:booking).where(bookings: { organisation_id: organisation })
                                    .includes(booking: :organisation).ordered
    end
  end
end
