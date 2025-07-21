# frozen_string_literal: true

# AccId:

# Integer; Booking type: 1=cost booking, 2=tax booking
# BType:

# Integer; This is the index of the booking that represents the cost booking which is attached to t
# his booking
# CIdx:

# String[9]; A user definable code.
# Code: nil,

# Date; The date of the booking.
# Date:

# IntegerAuxilliary flags. This entry consists of the sum of one or more of
# the following biases:
# 1 - The booking is the first one into the specified OP.
# 16 - This is a hidden booking. [Transitorische]
# 32 - This booking is the exit booking, as oposed to the return booking.
# Only valid if the hidden flag is set.
# Flags:

# String[5]; The Id of the tax. [MWSt-Kürzel]
# TaxId:

# MkTxB:

# String[61*]; This string specifies the first line of the booking text.
# Text:

#  String[*]; This string specifies the second line of the booking text.
# (*)Both fields Text and Text2 are stored in the same memory location,
# which means their total length may not exceed 60 characters (1 char is
# required internally).
# Be careful not to put too many characters onto one single line, because
# most Reports are not designed to display a full string containing 60
# characters.
# Text2:

# Integer; This is the index of the booking that represents the tax booking
# which is attached to this booking.
# TIdx: (entry.amount_type&.to_sym == :tax && entry.index) || nil,

# Boolean; Booking type.
# 0 a debit booking [Soll]
# 1 a credit booking [Haben]
# Type:

# Currency; The net amount for this booking. [Netto-Betrag]
# ValNt:

# Currency; The tax amount for this booking. [Brutto-Betrag]
# ValBt: entry.amount,

# Currency; The tax amount for this booking. [Steuer-Betrag]
# ValTx:

# Currency; The gross amount for this booking in the foreign currency specified
# by currency of the account AccId. [FW-Betrag]
# ValFW : not implemented

# String[13], This is the cost type account
# CAcc:

# String[13]The OP id of this booking.
# OpId: entry.ref,

# The PK number of this booking.
# PkKey:

module Export
  module Taf
    module Blocks
      class BatchEntry < Block
        Side = Struct.new(:side) do
          def initialize(side) = self.side = (side&.to_sym == :soll ? :soll : :haben)
          def soll? = side == :soll
          def haben? = side == :haben
          def inverted = Side.new(soll? ? :haben : :soll)
          def to_type = soll? ? 0 : 1
          def to_sym = side&.to_sym
        end

        def initialize(**properties, &)
          properties[:AccId] = Value.cast(properties[:AccId], as: :symbol)
          properties[:CAcc] = Value.cast(properties[:CAcc], as: :symbol)
          properties[:Text] = properties[:Text]&.slice(0..59)&.lines&.first&.strip # rubocop:disable Style/SafeNavigationChainLength
          super(:Bk, **properties, &)
        end

        def self.build_main_batch_entry(entry, side, **override) # rubocop:disable Metrics/CyclomaticComplexity,Metrics/AbcSize,Metrics/PerceivedComplexity
          return unless entry.valid?

          new(AccId: side.soll? ? entry.soll_account : entry.haben_account,
              # Code: nil,
              Date: entry.journal_entry_batch.date,
              TaxId: entry.vat_category&.accounting_vat_code || nil,
              Text: entry.text,
              # MkTxB: entry.vat_category&.accounting_vat_code.present?,
              Type: side.to_type,
              ValNt: entry.vat_breakup&.[](:netto) || entry.amount,
              ValTx: entry.vat_breakup&.[](:vat),
              CAcc: side.soll? ? entry.haben_account : entry.soll_account, **override)
        end

        def self.build_vat_batch_entry(entry, side, **override) # rubocop:disable Metrics/AbcSize
          return if entry.vat_category.blank? || entry.vat_breakup.blank?

          vat_account_nr = entry.journal_entry_batch.organisation.accounting_settings.vat_account_nr
          new(AccId: vat_account_nr,
              BType: 2,
              CAcc: side.soll? ? entry.haben_account : entry.soll_account,
              Date: entry.journal_entry_batch.date,
              Text: entry.text, Type: side.to_type,
              ValNt: entry.vat_breakup.[](:vat),
              ValTx: entry.vat_breakup.[](:netto),
              **override)
        end

        def self.build_cost_center_batch_entry(entry, side, **override)
          return if entry.cost_center.blank?

          new(AccId: entry.cost_center,
              BType: 1,
              Date: entry.journal_entry_batch.date,
              Text: entry.text, Type: side.to_type,
              ValNt: entry.vat_breakup&.[](:netto) || entry.amount,
              CAcc: side.soll? ? entry.soll_account : entry.haben_account,
              **override)
        end

        def self.build_with_journal_entry_batch(journal_entry_batch, primary_override: {}) # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
          primary_side, primary_account = determine_primary(journal_entry_batch)
          blocks = [build_primary_batch_entry(journal_entry_batch, primary_side, primary_account, **primary_override)]
          journal_entry_batch.entries.each do |entry|
            index = blocks.count + 1

            cost_center_block = build_cost_center_batch_entry(entry, primary_side.inverted)
            cost_index = cost_center_block.blank? ? nil : (index + 1)

            vat_block = build_vat_batch_entry(entry, primary_side.inverted)
            vat_index = vat_block.blank? ? nil : (index + (cost_center_block.blank? ? 1 : 2)) # rubocop:disable Style/NestedTernaryOperator

            main_block = build_main_batch_entry(entry, primary_side.inverted, CIdx: cost_index, TIdx: vat_index)
            blocks += [main_block, cost_center_block, vat_block].compact
          end.compact
          blocks
        end

        def self.determine_primary(journal_entry_batch) # rubocop:disable Metrics/MethodLength
          soll = [Side.new(:soll), journal_entry_batch.accounts[:soll].first]
          haben = [Side.new(:haben), journal_entry_batch.accounts[:haben].first]

          case journal_entry_batch.trigger&.to_sym
          when :invoice_created, :invoice_updated, :payment_reverted, :payment_discarded
            soll
          when :payment_created, :payment_updated, :invoice_reverted, :invoice_discarded
            # special case: paybacks
            if journal_entry_batch.is_a?(JournalEntryBatches::Payment) && journal_entry_batch.payment&.payback?
              return soll
            end

            haben
          else
            raise NotImplementedError
          end
        end

        def self.build_primary_batch_entry(journal_entry_batch, side, primary_account, **override)
          new(AccId: Value.cast(primary_account, as: :symbol),
              # CAcc: "div",
              Date: journal_entry_batch.date,
              Text: journal_entry_batch.text,
              Type: side.to_type,
              ValNt: journal_entry_batch.amount,
              PkKey: Value.cast(journal_entry_batch.booking.tenant.ref, as: :symbol),
              OpId: Value.cast(journal_entry_batch.invoice&.ref, as: :symbol),
              **override)
        end
      end
    end
  end
end
