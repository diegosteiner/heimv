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
  class JournalEntry < Tabular
    ::DataDigestTemplate.register_subtype self

    DEFAULT_COLUMN_CONFIG = [
      {
        header: ::JournalEntry.human_attribute_name(:date),
        body: '{{ journal_entry.date | date_format }}'
      },
      {
        header: ::JournalEntry.human_attribute_name(:source_document_ref),
        body: '{{ journal_entry.source_document_ref }}'
      },
      {
        header: ::JournalEntry.human_attribute_name(:text),
        body: '{{ journal_entry.text }}'
      },
      {
        header: ::JournalEntry.human_attribute_name(:soll_account),
        body: '{{ journal_entry.soll_account }}'
      },
      {
        header: ::JournalEntry.human_attribute_name(:haben_account),
        body: '{{ journal_entry.haben_account }}'
      },
      {
        header: ::JournalEntry.human_attribute_name(:amount),
        body: '{{ journal_entry.amount | round: 2 }}'
      },
      {
        header: ::JournalEntry.human_attribute_name(:vat_code),
        body: '{{ journal_entry.vat_code }}'
      },
      {
        header: ::JournalEntry.human_attribute_name(:book_type),
        body: '{{ journal_entry.book_type }}'
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

    formatter(:taf) do |_options = {}|
      records.to_a.group_by(&:invoice).map do |invoice, _journal_entries|
        TafBlock::Collection.new { derive(invoice) }
      end.join("\n\n")
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
                                    .includes(booking: :organisation).order(date: :ASC)
    end
  end
end
