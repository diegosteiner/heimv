class InterpolationService
  def self.call(subject)
    case subject
    when ::Contract
      Contract.new(subject).data
    when ::Invoice
      Invoice.new(subject).data
    else
      {}
    end
  end

  class Base
    attr_reader :data

    def flatten(hash, prepend_keys = [], joint = '_')
      return { prepend_keys => hash } unless hash.is_a?(Hash)

      hash.inject({}) do |memo, pair|
        memo.merge!(flatten(pair.last, (Array.wrap(prepend_keys) + [pair.first]).join(joint), joint))
      end
    end
  end

  class Contract < Base
    def initialize(contract)
      serializer = Public::ContractSerializer.new(contract)
      @data = flatten(serializer.serializable_hash(include: 'booking.occupancy,booking.tenant,booking.home'))
    end
  end

  class Invoice < Base
    def initialize(invoice)
      serializer = Public::InvoiceSerializer.new(invoice)
      @data = flatten(serializer.serializable_hash(include: 'booking.occupancy,booking.tenant,booking.home'))
    end
  end
end
