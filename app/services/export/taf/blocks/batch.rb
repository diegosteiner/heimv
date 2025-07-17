# frozen_string_literal: true

module Export
  module Taf
    module Blocks
      class Batch < Block
        def initialize(children = [], **properties, &)
          super(:Blg, children, **properties, &)
        end

        def self.build_with_journal_entry_batch(journal_entry_batch, **override)
          if journal_entry_batch.is_a?(JournalEntryBatches::Invoice) && journal_entry_batch.trigger_invoice_created?
            return build_with_invoice_created_journal_entry_batch(journal_entry_batch)
          end

          build_with_default_journal_entry_batch(journal_entry_batch)
        end

        def self.build_with_invoice_created_journal_entry_batch(journal_entry_batch, **override)
          [
            Address.build_with_tenant(journal_entry_batch.booking.tenant),
            PersonAccount.build_with_tenant(journal_entry_batch.booking.tenant),
            OpenPosition.build_with_invoice(journal_entry_batch.invoice),
            new(BatchEntry.build_with_journal_entry_batch(journal_entry_batch, primary_override: { Flags: 1 }),
                Date: journal_entry_batch.date, Orig: 1)
          ]
        end

        def self.build_with_default_journal_entry_batch(journal_entry_batch, **override)
          new(BatchEntry.build_with_journal_entry_batch(journal_entry_batch), Date: journal_entry_batch.date)
        end
      end
    end
  end
end
