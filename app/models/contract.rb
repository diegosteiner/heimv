class Contract < ApplicationRecord
  belongs_to :booking

  def sent?
    sent_at.present?
  end

  def signed?
    signed_at.present?
  end
end
