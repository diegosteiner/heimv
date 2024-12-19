# frozen_string_literal: true

module Public
  class VatCategorySerializer < ApplicationSerializer
    identifier :id
    fields :label, :label_i18n, :percentage, :accounting_vat_code
  end
end
