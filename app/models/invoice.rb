class Invoice < ApplicationRecord
  belongs_to :booking, inverse_of: :invoices
  has_many :invoice_parts, -> { order(position: :ASC) }, inverse_of: :invoice

  enum invoice_type: %i[invoice deposit late_notice]

  accepts_nested_attributes_for :invoice_parts, reject_if: :all_blank, allow_destroy: true

  def ref
    @ref ||= RefService.new.call(self) unless new_record?
  end

  def recalculate_amount
    update(amount: invoice_parts.reduce(0) { |result, invoice_part| invoice_part.inject_self(result) })
  end

  def filename
    "#{self.class.model_name.human}_#{booking.ref}_#{id}"
  end

  def amount_payed
    # payments.sum(&:amount)
    0
  end
end
