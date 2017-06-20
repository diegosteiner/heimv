class Person < ApplicationRecord
  def name
    "#{firstname} #{lastname}"
  end

  def to_s
    name
  end
end
