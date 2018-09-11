module TarifSelectors
  class AlwaysApply < TarifSelector
    def apply?(_usage, _distinction)
      true
    end
  end
end
