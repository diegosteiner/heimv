# frozen_string_literal: true

class CleanDataDigestsJob < ApplicationJob
  queue_as :default

  def perform
    DataDigest.where(DataDigest.arel_table[:created_at].lt(14.days.ago)).destroy_all
  end
end
