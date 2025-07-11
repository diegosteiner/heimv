# frozen_string_literal: true

class JournalEntryBatch
  class Filter < ApplicationFilter
    attribute :date_after, :date
    attribute :date_before, :date
    attribute :processed_at_after, :date
    attribute :processed_at_before, :date
    attribute :processed, :boolean
    attribute :triggers, array: true

    filter :date do |journal_entry_batches|
      next unless date_before.present? || date_after.present?

      journal_entry_batches.where(JournalEntryBatch.arel_table[:date].between(date_after..date_before))
    end

    filter :processed_at do |journal_entry_batches|
      next unless processed_at_before.present? || processed_at_after.present?

      journal_entry_batches.where(JournalEntryBatch.arel_table[:date].between(processed_at_after..processed_at_before))
    end

    filter :processed do |journal_entry_batches|
      next if processed.nil?

      processed ? journal_entry_batches.processed : journal_entry_batches.unprocessed
    end

    filter :triggers do |journal_entry_batches|
      trigger = Array.wrap(triggers) & JournalEntryBatch.triggers.keys
      next if triggers.blank?

      journal_entry_batches.where(trigger:)
    end
  end
end
