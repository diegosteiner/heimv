module Tarifs
  class Flat < Tarif
    def unit
      model_name.human
    end

    def prefill_usage_method
      :flat
    end
  end
end
