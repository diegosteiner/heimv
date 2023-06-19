# frozen_string_literal: true

class SchedulePlanBBackupsJob < ApplicationJob
  queue_as :default

  def perform
    Organisation.find_each do |organisation|
      PlanBBackupJob.perform_later(organisation.id)
    end
  end
end
