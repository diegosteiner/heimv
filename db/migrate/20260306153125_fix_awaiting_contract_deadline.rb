class FixAwaitingContractDeadline < ActiveRecord::Migration[8.1]
  def change
    Organisation.find_each do |organisation|
      organisation.deadline_settings.awaiting_contract_deadline +=
        organisation.deadline_settings.payment_overdue_deadline || 0
    end
  end
end
