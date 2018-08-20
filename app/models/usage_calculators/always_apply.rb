module UsageCalculators
  class AlwaysApply < UsageCalculator
    def calculate_apply(usage, _)
      usage.apply = true
    end
  end
end
