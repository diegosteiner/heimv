# frozen_string_literal: true

class PlanBBackupJob < ApplicationJob
  queue_as :default

  def perform(*args)
    organisation = Organisation.find(args.first)
    max_age = 1.month.ago

    organisation.plan_b_backups.create!
    organisation.plan_b_backups.where(PlanBBackup.arel_table[:created_at].lt(max_age)).destroy_all
  end
end
