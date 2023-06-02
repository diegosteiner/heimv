# frozen_string_literal: true

class CrunchDataDigestJob < ApplicationJob
  # queue_as :chrunch_data_digest
  discard_on ActiveJob::DeserializationError

  def perform(data_digest_id)
    data_digest = DataDigest.find(data_digest_id)
    return if data_digest.crunching_started_at.present? && data_digest.crunching_finished_at.blank?

    data_digest&.crunch!
  end
end
