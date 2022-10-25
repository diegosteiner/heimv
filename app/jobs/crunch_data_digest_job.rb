# frozen_string_literal: true

class CrunchDataDigestJob < ApplicationJob
  queue_as :chrunch_data_digest

  def perform(data_digest_id)
    data_digest = DataDigest.find(data_digest_id)
    data_digest&.crunch!
  end
end
