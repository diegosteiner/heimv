class Person < ApplicationRecord
  validates :firstname, :lastname, presence: true

  def name
    "#{firstname} #{lastname}"
  end

  def to_s
    name
  end
end
