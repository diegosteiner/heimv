# frozen_string_literal: true

module PaymentInfos
  class QrBill < ::PaymentInfo
    QRTYPE = 'SPC'
    VERSION = '0200'
    CODING_TYPE = '1'
    ADDRESS_TYPE = 'K'
    REF_TYPE = 'QRR' # || 'SCOR'
    CURRENCY = 'CHF'
    COUNTRY_CODE = 'CH'
    EPD = 'EPD'

    delegate :ref, :amount, :formatted_ref, to: :invoice

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def qr_data
      @qr_data ||= {
        qrtype: QRTYPE,
        version: VERSION,
        coding_type: CODING_TYPE,
        cr_account: creditor_account.delete(' '),
        cr_address_type: ADDRESS_TYPE,
        cr_name: creditor_address_lines[0],
        cr_address_line_1: creditor_address_lines[1],
        cr_address_line_2: creditor_address_lines[2],
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
        amount: formatted_amount,
        currency: CURRENCY,
        ezp_address_type: ADDRESS_TYPE,
        ezp_name: debitor_address_lines[0],
        ezp_address_line_1: debitor_address_lines[1],
        ezp_address_line_2: debitor_address_lines[2],
        ezp_zipcode: '',
        ezp_place: '',
        ezp_country: COUNTRY_CODE,
        ref_type: REF_TYPE,
        ref: ref,
        additional_information: '',
        trailer: EPD
      }.transform_values { _1.to_s.strip }
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength

    def creditor_address_lines
      @creditor_address_lines ||= organisation.address_lines
    end

    def debitor_address_lines
      @debitor_address_lines ||= invoice.invoice_address_lines
    end

    def creditor_account
      organisation.iban || ''
    end

    def currency
      CURRENCY
    end

    def formatted_amount
      format('%<amount>.2f', amount: amount)
    end

    def qrcode
      @qrcode ||= RQRCode::QRCode.new(qr_data.values.join("\n"), level: :h, mode: :byte_8bit)
    end
  end
end
