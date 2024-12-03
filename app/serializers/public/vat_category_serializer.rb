# frozen_string_literal: true

module Public
  class VatCategorySerializer < ApplicationSerializer
    fields :label_i18n, :percentage, :accounting_vat_code, :to_s
  end
end
