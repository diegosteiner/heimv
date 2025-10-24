# frozen_string_literal: true

module PaymentInfos
  class QrBill < ::PaymentInfo
    ::PaymentInfo.register_subtype self

    QRTYPE = 'SPC'
    VERSION = '0200'
    CODING_TYPE = '1'
    ADDRESS_TYPE = 'S'
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
    StructuredAddress = Struct.new(:name, :street, :street_nr, :zipcode, :city, :country_code)

    delegate :amount, :invoice_address, to: :invoice

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def qr_data # rubocop:disable Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
      @qr_data ||= {
        qrtype: QRTYPE,
        version: VERSION,
        coding_type: CODING_TYPE,
        cr_account: creditor_account&.to_s&.delete(' '),
        cr_address_type: ADDRESS_TYPE,
        cr_name: creditor_address&.recipient || '',
        cr_street: creditor_address&.street || '',
        cr_street_nr: creditor_address&.street_nr || '',
        cr_postalcode: creditor_address&.postalcode || '',
        cr_city: creditor_address&.city || '',
        cr_country: creditor_address&.country_code || COUNTRY_CODE,
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
        ezp_name: debitor_address&.recipient || '',
        ezp_street: debitor_address&.street || '',
        ezp_street_nr: debitor_address&.street_nr || '',
        ezp_zipcode: debitor_address&.postalcode || '',
        ezp_place: debitor_address&.city || '',
        ezp_country: debitor_address&.country_code || '',
        ref_type:,
        ref:,
        additional_information: '',
        trailer: EPD
      }.transform_values { it.to_s.strip }
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength

    def creditor_address
      @creditor_address ||= organisation.qr_bill_creditor_address.presence || Address.parse_lines(organisation.address)
    end

    def debitor_address
      @debitor_address ||= booking.invoice_address.presence || booking.tenant_address
    end

    def creditor_account
      @creditor_account ||= organisation.iban.to_s.presence
    end

    def currency
      organisation.currency.upcase
    end

    def show?
      invoice.amount.positive?
    end

    def formatted_amount(delimitter: ' ')
      ActiveSupport::NumberHelper.number_to_currency(amount, precision: 2, separator: '.', unit: '',
                                                             delimiter: delimitter)
    end

    def checksum(ref)
      base97_digits = ref.upcase.chars.map { CHAR_TABLE.index(it) } + RF00
      98 - (base97_digits.join.to_i % 97)
      # 98 - base97_digits.in_groups_of(7).reduce(base97_digits.shift(2)) do |check, digits|
      # ((check + digits).flatten.join.to_i % 97).to_s.chars
      # end.join.to_i
    end

    def ref_type
      organisation.iban&.qrr? ? :QRR : :SCOR
    end

    def scor_ref
      @scor_ref ||= format('RF%<checksum>02d%<unchecked_ref>s', checksum: checksum(invoice.payment_ref),
                                                                unchecked_ref: invoice.payment_ref)
    end

    def qrr_ref
      @qrr_ref ||= RefBuilders::InvoicePayment.with_checksum(invoice.payment_ref).rjust(27, '0')
    end

    def scor_ref?
      ref_type == :SCOR
    end

    def qrr_ref?
      ref_type == :QRR
    end

    def ref
      scor_ref? ? scor_ref : qrr_ref
    end

    def formatted_ref
      if scor_ref?
        ref.chars.in_groups_of(4).map(&:join).join(' ')
      else
        [ref[..1], ref[2..].chars.in_groups_of(5).map(&:join)].join(' ')
      end
    end

    def qrcode
      @qrcode ||= RQRCode::QRCode.new(qr_data.values.join("\n"), level: :m, mode: :byte_8bit)
    end
  end
end
