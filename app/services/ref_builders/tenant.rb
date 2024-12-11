# frozen_string_literal: true

module RefBuilders
  class Tenant < RefBuilder
    DEFAULT_TEMPLATE = '%<sequence_number>d'

    def initialize(tenant)
      super(tenant.organisation)
      @tenant = tenant
    end

    ref_part sequence_number: proc { @tenant.sequence_number }

    def generate(template_string = @organisation.tenant_accounting_ref_template)
      generate_lazy(template_string)
    end
  end
end
