module Tarifs
  class Flat < Tarif
    def unit
      model_name.human
    end

    def override_used_units?
      true
    end

    def override_used_units(_usage)
      1
    end
  end
end
