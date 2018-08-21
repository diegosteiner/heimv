module UsageCalculators
  class AlwaysApply < UsageCalculator
    def select_usage(usage, _distinction)
      usage.apply = true
    end
  end
end
