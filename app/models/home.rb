class Home < ApplicationRecord
  validates :name, :ref, presence: true
  has_one_attached :house_rules

  def to_s
    name
  end
end
