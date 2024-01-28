# frozen_string_literal: true

module PaymentInfos
  class QrBill < ::PaymentInfo
    ::PaymentInfo.register_subtype self

    QRTYPE = 'SPC'
    VERSION = '0200'
    CODING_TYPE = '1'
    ADDRESS_TYPE = 'K'
    # REF_TYPE = 'QRR'
    # REF_TYPE = 'SCOR'
    CURRENCY = 'CHF'
    COUNTRY_CODE = 'CH'
    EPD = 'EPD'
    CHAR_TABLE = %w[
      0 1 2 3 4 5 6 7 8 9
      A B C D E F G H I J K L M
      N O P Q R S T U V W X Y Z
    ].freeze
    RF00 = [2, 7, 1, 5, 0, 0].freeze

    delegate :amount, to: :invoice

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def qr_data
      @qr_data ||= {
        qrtype: QRTYPE,
        version: VERSION,
        coding_type: CODING_TYPE,
        cr_account: creditor_account&.to_s&.delete(' '),
        cr_address_type: ADDRESS_TYPE,
        cr_name: creditor_address_lines.fetch(0, ''),
        cr_address_line_1: creditor_address_lines.fetch(1, ''),
        cr_address_line_2: creditor_address_lines.fetch(2, ''),
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
        amount: formatted_amount(delimitter: ''),
        currency:,
        ezp_address_type: ADDRESS_TYPE,
        ezp_name: debitor_address_lines.fetch(0, ''),
        ezp_address_line_1: debitor_address_lines.fetch(1, ''),
        ezp_address_line_2: debitor_address_lines.fetch(2, ''),
        ezp_zipcode: '',
        ezp_place: '',
        ezp_country: COUNTRY_CODE,
        ref_type:,
        ref:,
        additional_information: '',
        trailer: EPD
      }.transform_values { _1.to_s.strip }
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength

    def creditor_address_lines
      @creditor_address_lines ||= organisation.creditor_address_lines || []
    end

    def debitor_address_lines
      @debitor_address_lines ||= invoice.invoice_address_lines || []
    end

    def creditor_account
      organisation.iban.to_s.presence
    end

    def currency
      organisation.currency.upcase
    end

    def show?
      invoice.amount.positive?
    end

    def formatted_amount(delimitter: ' ')
      ActiveSupport::NumberHelper.number_to_currency(amount, precision: 2, separator: '.',
                                                             unit: '', delimiter: delimitter)
    end

    def checksum(ref)
      base97_digits = ref.upcase.chars.map { CHAR_TABLE.index(_1) } + RF00
      98 - (base97_digits.flatten.join.to_i % 97)
      # 98 - base97_digits.in_groups_of(7).reduce(base97_digits.shift(2)) do |check, digits|
      # ((check + digits).flatten.join.to_i % 97).to_s.chars
      # end.join.to_i
    end

    def ref_type
      organisation.iban&.qrr? ? :QRR : :SCOR
    end

    def scor_ref
      @scor_ref ||= format('RF%<checksum>02d%<unchecked_ref>s', checksum: checksum(invoice.ref),
                                                                unchecked_ref: invoice.ref)
    end

    def qrr_ref
      invoice.ref.rjust(27, '0')
    end

    def ref
      ref_type == :SCOR ? scor_ref : qrr_ref
    end

    def formatted_ref
      [ref[..1], ref[2..].chars.in_groups_of(5).map(&:join)].join(' ')
    end

    def qrcode
      @qrcode ||= RQRCode::QRCode.new(qr_data.values.join("\n"), level: :m, mode: :byte_8bit)
    end
  end
end
