class QrPaymentSlip
  QRTYPE = 'SPC'.freeze
  VERSION = '0200'.freeze
  CODING_TYPE = '1'
  ADDRESS_TYPE = 'S'
  REF_TYPE = 'QRR'
  CURRENCY = 'CHF'

  delegate :organisation, :booking to: :invoice

  def initialize(invoice)
    @invoice = invoice
    @qr_data =   {
      qrtype: QRTYPE,
      version: VERSION,
      coding_type: CODING_TYPE,
      account_nr: organisation.account_nr.to_s,
      ze_address_type: ADDRESS_TYPE,
      ze_name: organisation.name,
      ze_address_line_1: organisation.address.lines[0],
      ze_address_line_2: organisation.address.lines[1],
      ze_zipcode: organisation.zipcode,
      ze_place: organisation.place,
      ze_country: organisation.country_code,
      eze_address_type: '',
      eze_name: '',
      eze_address_line_1: '',
      eze_address_line_2: '',
      eze_zipcode: '',
      eze_place: '',
      eze_country: '',
      amount: invoice.amount.to_s,
      currency: CURRENCY,
      ezp_Adress_Typ: ADDRESS_TYPE,
      ezp_name: invoice.address.name,
      ezp_address_line_1: invoice.address.lines[0],
      ezp_address_line_2: invoice.address.lines[1],
      ezp_zipcode: invoice.address.zipcode,
      ezp_place: invoice.address.place,
      ezp_country: invoivce.address.country_code,
      ref_type: REF_TYPE,
      ref: invoice.ref,
    }
  end

  def payload
    qr_data.values.map("\n")
  end
end
