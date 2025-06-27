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

      def journal_entry_batch_entry(entry, override = {})
        block(:Bk,
              AccId: Value.cast(entry.account_nr, as: :symbol),

              # Integer; Booking type: 1=cost booking, 2=tax booking
              BType: { main: nil, cost: 1, vat: 2 }[entry.book_type&.to_sym],

              # Integer; This is the index of the booking that represents the cost booking which is attached to t
              # his booking
              # CIdx: entry.index,

              # String[9]; A user definable code.
              # Code: nil,

              # Date; The date of the booking.
              Date: entry.journal_entry_batch.date,

              # IntegerAuxilliary flags. This entry consists of the sum of one or more of
              # the following biases:
              # 1 - The booking is the first one into the specified OP.
              # 16 - This is a hidden booking. [Transitorische]
              # 32 - This booking is the exit booking, as oposed to the return booking.
              # Only valid if the hidden flag is set.
              Flags: nil,

              # String[5]; The Id of the tax. [MWSt-Kürzel]
              TaxId: (entry.book_type_main? && entry.vat_category&.percentage&.positive? &&
                            entry.vat_category&.accounting_vat_code) || nil,

              # MkTxB: entry.vat_category&.accounting_vat_code.present?,

              # String[61*]; This string specifies the first line of the booking text.
              Text: entry.text&.slice(0..59)&.lines&.first&.strip || '-', # rubocop:disable Style/SafeNavigationChainLength

              #  String[*]; This string specifies the second line of the booking text.
              # (*)Both fields Text and Text2 are stored in the same memory location,
              # which means their total length may not exceed 60 characters (1 char is
              # required internally).
              # Be careful not to put too many characters onto one single line, because
              # most Reports are not designed to display a full string containing 60
              # characters.
              Text2: entry.text&.slice(0..59)&.lines&.[](1..)&.join("\n").presence, # rubocop:disable Style/SafeNavigationChainLength

              # Integer; This is the index of the booking that represents the tax booking
              # which is attached to this booking.
              # TIdx: (entry.amount_type&.to_sym == :tax && entry.index) || nil,

              # Boolean; Booking type.
              # 0 a debit booking [Soll]
              # 1 a credit booking [Haben]
              Type: { soll: 0, haben: 1 }[entry.side&.to_sym],

              # Currency; The net amount for this booking. [Netto-Betrag]
              ValNt: entry.amount,

              # Currency; The tax amount for this booking. [Brutto-Betrag]
              # ValBt: entry.amount,

              # Currency; The tax amount for this booking. [Steuer-Betrag]
              ValTx: {
                vat: entry.vat_breakup&.[](:netto),
                main: entry.vat_breakup&.[](:vat)
              }[entry.book_type&.to_sym],

              # Currency; The gross amount for this booking in the foreign currency specified
              # by currency of the account AccId. [FW-Betrag]
              # ValFW : not implemented

              # String[13], This is the cost type account
              # CAcc: (Value.cast(entry.cost_account_nr, as: :symbol) if entry.cost_account_nr),
              CAcc: entry.book_type_cost? && Value.cast(entry.related(:main)&.account_nr, as: :symbol),

              # String[13]The OP id of this booking.
              # OpId: entry.ref,

              # The PK number of this booking.
              PkKey: nil,
              **override)
      end

      def journal_entry_batch(journal_entry_batch)
        op_id = Value.cast(journal_entry_batch.invoice&.ref, as: :symbol)
        pk_key = Value.cast(journal_entry_batch.booking.tenant.ref, as: :symbol)

        case journal_entry_batch.trigger&.to_sym
        when :invoice_created
          tenant(journal_entry_batch.booking.tenant)
          open_position(journal_entry_batch, op_id, pk_key)
          default_journal_entry_batch(journal_entry_batch, { Orig: true },
                                      { 0 => { Flags: 1, OpId: op_id, PkKey: pk_key } })
        else
          create = journal_entry_batch.trigger_invoice_created? || journal_entry_batch.trigger_payment_created?
          default_journal_entry_batch(journal_entry_batch, { Orig: create }, { 0 => { OpId: op_id, PkKey: pk_key } })
        end
      end

      def default_journal_entry_batch(journal_entry_batch, override = {}, overrides = {})
        return if journal_entry_batch.entries.blank?

        block(:Blg, Date: journal_entry_batch.date, **override) do
          journal_entry_batch.entries.each_with_index do |entry, index|
            cost_index = (entry.book_type_main? && journal_entry_batch.entries.index(entry.related(:cost))) || nil
            vat_index = (entry.book_type_main? && journal_entry_batch.entries.index(entry.related(:vat))) || nil

            journal_entry_batch_entry(entry, { CIdx: cost_index&.+(1), TIdx: vat_index&.+(1),
                                               **overrides.fetch(:all, {}), **overrides.fetch(index, {}) })
          end
        end
      end

      def open_position(journal_entry_batch, op_id, pk_key)
        block(:OPd, PkKey: pk_key, OpId: op_id, ZabId: '15T', Ref: journal_entry_batch.invoice&.payment_ref,
                    Text: journal_entry_batch.text)
      end

      def tenant(tenant, _override = {})
        account_nr = Value.cast(tenant.ref, as: :symbol)

        block(:Adr, AdrId: account_nr,
                    Sort: I18n.transliterate(tenant.full_name).gsub(/\s/, '').upcase,
                    Corp: tenant.full_name,
                    Lang: 'D',
                    Road: tenant.street_address,
                    CCode: tenant.country_code,
                    ACode: tenant.zipcode,
                    City: tenant.city)
        block(:PKd, PkKey: account_nr,
                    AdrId: account_nr,
                    AccId: Value.cast(tenant.organisation.accounting_settings.debitor_account_nr, as: :symbol),
                    ZabId: '15T')
      end

      def block(type, **properties, &)
        blocks << Block.new(type, **properties, &)
      end
    end
  end
end

# rubocop:enable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/MethodLength,Metrics/PerceivedComplexity
