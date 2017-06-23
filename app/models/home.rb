class Home < ApplicationRecord
  validates :name, :ref, presence: true

  def to_s
    name
  end
end
