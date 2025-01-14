# frozen_string_literal: true

# rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/MethodLength,Metrics/PerceivedComplexity

module Export
  module Taf
    class Builder
      attr_reader :blocks

      delegate :to_a, :[], :<<, to: :blocks

      def initialize(&)
        @blocks = []
        instance_exec(&) if block_given?
      end

      def build_with_journal_entry(journal_entry, **override)
        build(:Bk, **{
                # The Id of a book keeping account. [Fibu-Konto]
                AccId: Value.cast(journal_entry.account_nr, as: :symbol),

                # Integer; Booking type: 1=cost booking, 2=tax booking
                BType: { main: nil, cost: 1, vat: 2 }[journal_entry.book_type&.to_sym],

                # String[13], This is the cost type account
                # CAcc: (Value.cast(journal_entry.cost_account_nr, as: :symbol) if journal_entry.cost_account_nr),

                # Integer; This is the index of the booking that represents the cost booking which is attached to t
                # his booking
                # CIdx: journal_entry.index,

                # String[9]; A user definable code.
                Code: journal_entry.id,

                # Date; The date of the booking.
                Date: journal_entry.date,

                # IntegerAuxilliary flags. This journal_entry consists of the sum of one or more of
                # the following biases:
                # 1 - The booking is the first one into the specified OP.
                # 16 - This is a hidden booking. [Transitorische]
                # 32 - This booking is the exit booking, as oposed to the return booking.
                # Only valid if the hidden flag is set.
                Flags: nil,

                # String[5]; The Id of the tax. [MWSt-Kürzel]
                TaxId: (journal_entry.book_type_main? && journal_entry.vat_category&.percentage&.positive? &&
                      journal_entry.vat_category&.accounting_vat_code) || nil,

                # MkTxB: journal_entry.vat_category&.accounting_vat_code.present?,

                # String[61*]; This string specifies the first line of the booking text.
                Text: journal_entry.text&.slice(0..59)&.lines&.first&.strip || '-', # rubocop:disable Style/SafeNavigationChainLength

                #  String[*]; This string specifies the second line of the booking text.
                # (*)Both fields Text and Text2 are stored in the same memory location,
                # which means their total length may not exceed 60 characters (1 char is
                # required internally).
                # Be careful not to put too many characters onto one single line, because
                # most Reports are not designed to display a full string containing 60
                # characters.
                Text2: journal_entry.text&.slice(0..59)&.lines&.[](1..)&.join("\n").presence, # rubocop:disable Style/SafeNavigationChainLength

                # Integer; This is the index of the booking that represents the tax booking
                # which is attached to this booking.
                # TIdx: (journal_entry.amount_type&.to_sym == :tax && journal_entry.index) || nil,

                # Boolean; Booking type.
                # 0 a debit booking [Soll]
                # 1 a credit booking [Haben]
                Type: { soll: 0, haben: 1 }[journal_entry.side&.to_sym],

                # Currency; The net amount for this booking. [Netto-Betrag]
                ValNt: journal_entry.amount,

                # Currency; The tax amount for this booking. [Brutto-Betrag]
                # ValBt: journal_entry.amount,

                # Currency; The tax amount for this booking. [Steuer-Betrag]
                ValTx: journal_entry.book_type_vat? &&
                      journal_entry.vat_category&.breakup(vat: journal_entry.amount)&.[](:netto),

                # Currency; The gross amount for this booking in the foreign currency specified
                # by currency of the account AccId. [FW-Betrag]
                # ValFW : not implemented

                # String[13]The OP id of this booking.
                # OpId: journal_entry.ref,

                # The PK number of this booking.
                PkKey: nil
              }, **override)
      end

      def build_with_payment(payment, **_override)
        raise StandardError, 'Abschreibung is not yet supported' if payment.write_off

        # op_id = Value.cast(payment.invoice.ref, as: :symbol)
        # pk_key = Value.cast(payment.invoice.booking.tenant.ref, as: :symbol)
        payment.journal_entries.to_a.map do |journal_entry|
          build_with_journal_entry(journal_entry)
        end
      end

      def build_with_journal_entry_compound(compound)
        case compound.common[:trigger]&.to_sym
        when :invoice_created
          build_with_invoice_created_journal_entry_compound(compound)
        when :payment_created
          build_with_payment_created_journal_entry_compound(compound)
        end
      end

      def build_with_payment_created_journal_entry_compound(compound)
        build(:Blg, **{ Date: compound.common[:date] }) do
          journal_entries = compound.journal_entries
          compound.journal_entries.each_with_index do |journal_entry, index|
            cost_index = (journal_entry.book_type_main? && journal_entries.index(journal_entry.related[:cost])) || nil
            vat_index = (journal_entry.book_type_main? && journal_entries.index(journal_entry.related[:vat])) || nil
            taf_index = index + 1
            build_with_journal_entry(journal_entry, CIdx: cost_index&.+(taf_index), TIdx: vat_index&.+(taf_index))
          end
        end
      end

      def build_with_invoice_created_journal_entry_compound(compound)
        booking = Booking.find compound.common[:booking_id]
        op_id = Value.cast(compound.common[:ref], as: :symbol)
        pk_key = Value.cast(booking.tenant.ref, as: :symbol)
        journal_entries = compound.journal_entries.dup

        [
          build_with_tenant(booking.tenant),
          build(:OPd, **{ PkKey: pk_key, OpId: op_id, ZabId: '15T' }),
          build(:Blg, **{ Date: compound.common[:date], Orig: true }) do
            # TODO: check if this is really the debitor_journal_entry
            creation_journal_entry = journal_entries.shift
            build_with_journal_entry(creation_journal_entry, Flags: 1, OpId: op_id, PkKey: pk_key, CAcc: :div)

            journal_entries.each_with_index do |journal_entry, index|
              cost_index = (journal_entry.book_type_main? && journal_entries.index(journal_entry.related[:cost])) || nil
              vat_index = (journal_entry.book_type_main? && journal_entries.index(journal_entry.related[:vat])) || nil
              taf_index = index + 2
              build_with_journal_entry(journal_entry, CIdx: cost_index&.+(taf_index), TIdx: vat_index&.+(taf_index),
                                                      CAcc: Value.cast(creation_journal_entry.account_nr, as: :symbol))
            end
          end
        ]
      end

      def build_with_tenant(tenant, **_override)
        account_nr = Value.cast(tenant.ref, as: :symbol)
        [
          build(:Adr, **{
                  AdrId: account_nr,
                  Sort: I18n.transliterate(tenant.full_name).gsub(/\s/, '').upcase,
                  Corp: tenant.full_name,
                  Lang: 'D',
                  Road: tenant.street_address,
                  CCode: tenant.country_code,
                  ACode: tenant.zipcode,
                  City: tenant.city
                }),
          build(:PKd, **{
                  PkKey: account_nr,
                  AdrId: account_nr,
                  AccId: Value.cast(tenant.organisation.accounting_settings.debitor_account_nr, as: :symbol),
                  ZabId: '15T'
                })

        ]
      end

      def build(type, **properties, &)
        children = (block_given? && Builder.new(&).blocks) || []
        Block.new(type, children, **properties).tap { blocks << _1 }
      end
    end
  end
end

# rubocop:enable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/MethodLength,Metrics/PerceivedComplexity
