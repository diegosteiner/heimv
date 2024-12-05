# frozen_string_literal: true

class TafBlock
  INDENTOR = '  '
  SEPARATOR = "\n"
  attr_reader :type, :properties, :children

  def initialize(type, **properties, &)
    @type = type
    @properties = properties.to_h
    @children = Collection.new(&)
  end

  def self.block(...)
    new(...)
  end

  Value = Data.define(:value) do
    delegate :to_s, to: :value

    def self.derive(value)
      new derive_value(value)
    end

    def self.derive_value(value) # rubocop:disable Metrics/CyclomaticComplexity,Metrics/MethodLength
      case value
      when ::FalseClass, ::TrueClass
        value ? '1' : '0'
      when ::BigDecimal, ::Float
        format('%.2f', value)
      when ::Numeric
        value.to_s
      when ::Date, ::DateTime, ::ActiveSupport::TimeWithZone
        value.strftime('%d.%m.%Y')
      when ::String
        "\"#{value.gsub(/["']/, '""')}\""
      when ::Enumerable
        "[#{value.to_a.each { derive_value(_1) }.join(',')}]"
      when Value
        value
      else
        derive_value value.to_s
      end
    end
  end

  class Collection
    delegate_missing_to :@blocks

    def initialize(&)
      @blocks = []
      instance_eval(&) if block_given?
    end

    def block(...)
      @blocks += Array.wrap(TafBlock.new(...))
    end

    def derive(...)
      @blocks += Array.wrap(TafBlock.derive(...))
    end

    def serialize(indent_level: 0, indent_with: '  ', separate_with: "\n")
      @blocks.map do |block|
        block.serialize(indent_level: indent_level + 1, indent_with:, separate_with:) if block.is_a?(TafBlock)
      end.compact.join(separate_with + separate_with)
    end

    def to_s
      serialize(indent_level: -1)
    end
  end

  def serialize(indent_level: 0, indent_with: '  ', separate_with: "\n")
    indent = [indent_with * indent_level].join
    separate_and_indent = [separate_with, indent, indent_with].join
    serialized_children = children.serialize(indent_level:, indent_with:, separate_with:)
    serialized_properties = properties.compact.map { |key, value| "#{key}=#{Value.derive(value)}" }

    [ # tag_start
      indent, "{#{type}",
      # properties
      separate_and_indent, serialized_properties.join(separate_and_indent),
      # children
      (serialized_children.present? && separate_with) || nil, serialized_children,
      # tag end
      separate_with, indent, '}'
    ].compact.join
  end

  def to_s
    serialize
  end

  def self.factories
    @factories ||= {}
  end

  def self.derive_from(klass, &derive_block)
    factories[klass] = derive_block
  end

  def self.derive(value, **override, &block)
    derive_block = factories[factories.keys.find { |klass| value.is_a?(klass) }]
    instance_exec(value, override, block, &derive_block) if derive_block.present?
  end

  derive_from Accounting::JournalEntryGroup do |value, **override|
    new(:Blg, **{
          # Date; The date of the booking.
          Date: override.fetch(:Date, value.date),

          Orig: true
        })
  end

  derive_from Accounting::JournalEntry do |journal_entry, **override|
    new(:Bk, **{
          # The Id of a book keeping account. [Fibu-Konto]
          AccId: journal_entry.account,

          # Integer; Booking type: 1=cost booking, 2=tax booking
          BType: journal_entry.amount_type&.to_sym == :tax || 1,

          # String[13], This is the cost type account
          CAcc: journal_entry.cost_center,

          # Integer; This is the index of the booking that represents the cost booking which is attached to this booking
          CIdx: journal_entry.index,

          # String[9]; A user definable code.
          Code: nil,

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
          TaxId: journal_entry.tax_code,

          # String[61*]; This string specifies the first line of the booking text.
          Text: journal_entry.text&.slice(0..59)&.lines&.first&.strip || '-', # rubocop:disable Style/SafeNavigationChainLength

          #  String[*]; This string specifies the second line of the booking text.
          # (*)Both fields Text and Text2 are stored in the same memory location,
          # which means their total length may not exceed 60 characters (1 char is
          # required internally).
          # Be careful not to put too many characters onto one single line, because
          # most Reports are not designed to display a full string containing 60
          # characters.
          Text2: journal_entry.text&.slice(0..59)&.lines&.[](1..-1)&.join("\n").presence, # rubocop:disable Style/SafeNavigationChainLength

          # Integer; This is the index of the booking that represents the tax booking
          # which is attached to this booking.
          TIdx: (journal_entry.amount_type&.to_sym == :tax && journal_entry.index) || nil,

          # Boolean; Booking type.
          # 0 a debit booking [Soll]
          # 1 a credit booking [Haben]
          Type: { soll: 0, haben: 1 }[journal_entry.side],

          # Currency; The net amount for this booking. [Netto-Betrag]
          ValNt: journal_entry.amount_type&.to_sym == :netto ? journal_entry.amount : nil,

          # Currency; The tax amount for this booking. [Brutto-Betrag]
          ValBt: journal_entry.amount_type&.to_sym == :brutto ? journal_entry.amount : nil,

          # Currency; The tax amount for this booking. [Steuer-Betrag]
          ValTx: journal_entry.amount_type&.to_sym == :tax ? journal_entry.amount : nil,

          # Currency; The gross amount for this booking in the foreign currency specified
          # by currency of the account AccId. [FW-Betrag]
          # ValFW : not implemented

          # String[13]The OP id of this booking.
          OpId: journal_entry.reference,

          # The PK number of this booking.
          PkKey: nil
        }, **override)
  end

  derive_from Invoice do |invoice, **override|
    next unless invoice.is_a?(Invoices::Invoice) || invoice.is_a?(Invoices::Deposit)

    op_id = invoice.human_ref
    pk_key = [Value.new(invoice.booking.tenant.accounting_debitor_account_nr),
              Value.new(invoice.organisation.accounting_settings.currency_account_nr)]
    journal_entries = invoice.journal_entries.to_a

    [
      new(:OPd, **{ PkKey: pk_key, OpId: op_id, ZabId: '15T' }, **override),
      new(:Blg, **{ OpId: op_id, Date: invoice.issued_at, Orig: true }, **override) do
        derive(journal_entries.shift, Flags: 1, OpId: op_id)
        journal_entries.each { derive(_1, OpId: op_id) }
      end
    ]
  end
end
