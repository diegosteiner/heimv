# frozen_string_literal: true

class PlanBBackupJob < ApplicationJob
  queue_as :default

  def perform
    max_age = 1.month.ago

    Organisation.find_each batch_size: 1 do |organisation|
      organisation.plan_b_backups.create!
      organisation.plan_b_backups.where(PlanBBackup.arel_table[:created_at].lt(max_age)).destroy_all
    end
  end
end
