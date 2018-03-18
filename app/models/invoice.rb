class Invoice < ApplicationRecord
  belongs_to :booking

  validates :booking, presence: true
end
