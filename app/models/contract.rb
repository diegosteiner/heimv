class Contract < ApplicationRecord
  belongs_to :booking

  def sent?
    sent_at.present?
  end

  def signed?
    sent_at.present?
  end
end
