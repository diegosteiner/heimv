# frozen_string_literal: true

module Export
  module Pdf
    module Renderables
      class AddressedHeader < Renderable
        attr_reader :booking

        delegate :organisation, to: :booking

        def initialize(booking, use_invoice_address: false)
          super()
          @booking = booking
          @use_invoice_address = use_invoice_address
        end

        def issuer_address
          organisation.representative_address.presence || organisation.address
        end

        def represented_issuer
          organisation.representative_address.presence && organisation.name
        end

        def recipient_address
          @use_invoice_address && booking.invoice_address.presence || booking.tenant.full_address_lines
        end

        def represented_recipient
          booking.tenant_organisation.presence
        end

        def render_into(document)
          Renderables::Address.new(issuer_address, issuer: true,
                                                   label: Contract.human_attribute_name('issuer'),
                                                   representing: represented_issuer).render_into(document)

          Renderables::Address.new(recipient_address, label: Tenant.model_name.human,
                                                      representing: represented_recipient).render_into(document)
        end
      end
    end
  end
end
