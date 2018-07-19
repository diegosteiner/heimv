module InvoiceParts
  class Add < InvoicePart
    def inject_self(result)
      result + amount
    end
  end
end
