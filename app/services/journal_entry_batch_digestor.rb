# frozen_string_literal: true

class JournalEntryBatchDigestor
  def initialize(organisation)
    @organisation = organisation
  end

  def digest_and_process!(journal_entry_batches, data_digest_template_id:, period:, process: true)
    data_digest_template = data_digest_templates.find(data_digest_template_id)
    return if data_digest_template.blank? || journal_entry_batches.blank?

    journal_entry_batches = data_digest_template.prefilter.apply(journal_entry_batches)
    journal_entry_batches = data_digest_template.periodfilter(period).apply(journal_entry_batches)
    data_digest = data_digest_template.digest(period.presence)
    return unless data_digest.update(record_ids: journal_entry_batches.pluck(:id))

    CrunchDataDigestJob.perform_later(data_digest.id)
    journal_entry_batches.unprocessed.update_all(processed_at: Time.zone.now) if process.present? # rubocop:disable Rails/SkipsModelValidations

    data_digest
  end

  def data_digest_templates
    @organisation.data_digest_templates.where(type: DataDigestTemplates::JournalEntry.sti_name)
  end
end
