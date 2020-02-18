module Public
  class HomeSerializer < ApplicationSerializer
    attributes :name, :ref, :janitor, :place, :min_occupation
  end
end
