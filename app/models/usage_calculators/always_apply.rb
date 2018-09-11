module UsageCalculators
  class AlwaysApply < UsageCalculator
    def select_usage(_usage, _distinction)
      true
    end
  end
end
