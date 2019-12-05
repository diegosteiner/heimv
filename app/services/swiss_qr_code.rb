class SwissQrCode
  QRTYPE = 'SPC'.freeze
  VERSION = '0200'.freeze
  CODING_TYPE = '1'.freeze
  ADDRESS_TYPE = 'K'.freeze
  REF_TYPE = 'QRR'.freeze
  CURRENCY = 'CHF'.freeze
  COUNTRY_CODE = 'CH'.freeze

  attr_reader :invoice

  delegate :organisation, :booking, to: :invoice

  def initialize(invoice)
    @invoice = invoice
  end

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  def qr_data
    @qr_data ||= {
      qrtype: QRTYPE,
      version: VERSION,
      coding_type: CODING_TYPE,
      esr_participant_nr: organisation.iban&.delete(' ') || '',
      cr_address_type: ADDRESS_TYPE,
      cr_name: organisation.address.lines[0],
      cr_address_line_1: organisation.address.lines[1],
      cr_address_line_2: organisation.address.lines[2],
      cr_zipcode: '',
      cr_place: '',
      cr_country: COUNTRY_CODE,
      ucr_address_type: '',
      ucr_name: '',
      ucr_address_line_1: '',
      ucr_address_line_2: '',
      ucr_zipcode: '',
      ucr_place: '',
      ucr_country: '',
      amount: invoice.amount.to_s,
      currency: CURRENCY,
      ezp_address_type: ADDRESS_TYPE,
      ezp_name: invoice.address_lines[0],
      ezp_address_line_1: invoice.address_lines[1],
      ezp_address_line_2: invoice.address_lines[2],
      ezp_zipcode: '',
      ezp_place: '',
      ezp_country: COUNTRY_CODE,
      ref_type: REF_TYPE,
      ref: invoice.ref,
      additional_information: ''
    }.transform_values { |value| value.to_s.strip }
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength

  def qrcode
    @qrcode ||= RQRCode::QRCode.new(qr_data.values.join("\n"), level: :m)
  end
end
