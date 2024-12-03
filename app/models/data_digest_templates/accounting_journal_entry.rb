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
  class AccountingJournalEntry < ::DataDigestTemplate
    ::DataDigestTemplate.register_subtype self

    def periodfilter(period = nil)
      filter_class.new(issued_at_after: period&.begin, issued_at_before: period&.end)
    end

    def filter_class
      ::Invoice::Filter
    end

    def base_scope
      @base_scope ||= ::Invoice.joins(:booking).where(bookings: { organisation_id: organisation }).kept
    end

    def crunch(records)
      invoice_ids = records.pluck(:id).uniq
      base_scope.where(id: invoice_ids).find_each(cursor: []).flat_map do |invoice|
        invoice.journal_entry
      end
    end

    formatter(:taf) do |_options = {}|
      data.flat_map do |record|
        journal_entry = ::Accounting::JournalEntryGroup.new(**record)
        [
          TafBlock.build_from(journal_entry)
        ]
      end.join("\n")
    end
  end
end
