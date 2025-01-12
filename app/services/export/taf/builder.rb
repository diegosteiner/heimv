# frozen_string_literal: true

# rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/MethodLength,Metrics/PerceivedComplexity

module Export
  module Taf
    class Builder
      attr_reader :blocks

      def initialize
        @blocks = []
      end

      def self.build(&)
        builder = new
        builder.instance_exec(&) if block_given?
        builder.blocks
      end

      def journal_entry_fragment(fragment, override = {})
        block(:Bk, **{
                # The Id of a book keeping account. [Fibu-Konto]
                AccId: Value.cast(fragment.account_nr, as: :symbol),

                # Integer; Booking type: 1=cost booking, 2=tax booking
                BType: { main: nil, cost: 1, vat: 2 }[fragment.book_type&.to_sym],

                # String[13], This is the cost type account
                # CAcc: (Value.cast(fragment.cost_account_nr, as: :symbol) if fragment.cost_account_nr),

                # Integer; This is the index of the booking that represents the cost booking which is attached to t
                # his booking
                # CIdx: fragment.index,

                # String[9]; A user definable code.
                # Code: nil,

                # Date; The date of the booking.
                Date: fragment.journal_entry.date,

                # IntegerAuxilliary flags. This fragment consists of the sum of one or more of
                # the following biases:
                # 1 - The booking is the first one into the specified OP.
                # 16 - This is a hidden booking. [Transitorische]
                # 32 - This booking is the exit booking, as oposed to the return booking.
                # Only valid if the hidden flag is set.
                Flags: nil,

                # String[5]; The Id of the tax. [MWSt-Kürzel]
                TaxId: (fragment.book_type_main? && fragment.vat_category&.percentage&.positive? &&
                      fragment.vat_category&.accounting_vat_code) || nil,

                # MkTxB: fragment.vat_category&.accounting_vat_code.present?,

                # String[61*]; This string specifies the first line of the booking text.
                Text: fragment.text&.slice(0..59)&.lines&.first&.strip || '-', # rubocop:disable Style/SafeNavigationChainLength

                #  String[*]; This string specifies the second line of the booking text.
                # (*)Both fields Text and Text2 are stored in the same memory location,
                # which means their total length may not exceed 60 characters (1 char is
                # required internally).
                # Be careful not to put too many characters onto one single line, because
                # most Reports are not designed to display a full string containing 60
                # characters.
                Text2: fragment.text&.slice(0..59)&.lines&.[](1..)&.join("\n").presence, # rubocop:disable Style/SafeNavigationChainLength

                # Integer; This is the index of the booking that represents the tax booking
                # which is attached to this booking.
                # TIdx: (fragment.amount_type&.to_sym == :tax && fragment.index) || nil,

                # Boolean; Booking type.
                # 0 a debit booking [Soll]
                # 1 a credit booking [Haben]
                Type: { soll: 0, haben: 1 }[fragment.side&.to_sym],

                # Currency; The net amount for this booking. [Netto-Betrag]
                ValNt: fragment.amount,

                # Currency; The tax amount for this booking. [Brutto-Betrag]
                # ValBt: fragment.amount,

                # Currency; The tax amount for this booking. [Steuer-Betrag]
                ValTx: fragment.book_type_vat? &&
                      fragment.vat_category&.breakup(vat: fragment.amount)&.[](:netto),

                # Currency; The gross amount for this booking in the foreign currency specified
                # by currency of the account AccId. [FW-Betrag]
                # ValFW : not implemented

                # String[13]The OP id of this booking.
                # OpId: fragment.ref,

                # The PK number of this booking.
                PkKey: nil
              }, **override)
      end

      def journal_entry(journal_entry)
        case journal_entry.trigger&.to_sym
        when :invoice_created
          invoice_created_journal_entry(journal_entry)
        when :payment_created
          default_journal_entry(journal_entry)
        end
      end

      def default_journal_entry(journal_entry, overrides = {})
        block(:Blg, **{ Date: journal_entry.date }) do
          journal_entry.fragments.each_with_index do |fragment, index|
            cost_index = (fragment.book_type_main? && journal_entry.fragments.index(fragment.related(:cost))) || nil
            vat_index = (fragment.book_type_main? && journal_entry.fragments.index(fragment.related(:vat))) || nil

            journal_entry_fragment(fragment, { CIdx: cost_index&.+(1), TIdx: vat_index&.+(1),
                                               **overrides.fetch(:all, {}), **overrides.fetch(index, {}) })
          end
        end
      end

      def invoice_created_journal_entry(journal_entry)
        op_id = Value.cast(journal_entry.invoice&.ref, as: :symbol)
        pk_key = Value.cast(journal_entry.booking.tenant.ref, as: :symbol)

        tenant(journal_entry.booking.tenant)
        block(:OPd, **{ PkKey: pk_key, OpId: op_id, ZabId: '15T' })
        default_journal_entry(journal_entry, { 0 => { Flags: 1, OpId: op_id, PkKey: pk_key } })
        # journal_entry.children[0].properties.merge!(Flags: 1, OpId: op_id, PkKey: pk_key, CAcc: :div)
        # journal_entry.children.each { _1.properties.merge!(CAcc: Value.cast(creation_journal_entry.account_nr,
        # as: :symbol))) }
      end

      def tenant(tenant, _override = {})
        account_nr = Value.cast(tenant.ref, as: :symbol)

        block(:Adr, **{
                AdrId: account_nr,
                Sort: I18n.transliterate(tenant.full_name).gsub(/\s/, '').upcase,
                Corp: tenant.full_name,
                Lang: 'D',
                Road: tenant.street_address,
                CCode: tenant.country_code,
                ACode: tenant.zipcode,
                City: tenant.city
              })
        block(:PKd, **{
                PkKey: account_nr,
                AdrId: account_nr,
                AccId: Value.cast(tenant.organisation.accounting_settings.debitor_account_nr, as: :symbol),
                ZabId: '15T'
              })
      end

      def block(type, **properties, &)
        blocks << Block.new(type, **properties, &)
      end
    end
  end
end

# rubocop:enable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/MethodLength,Metrics/PerceivedComplexity
