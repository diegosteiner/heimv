# frozen_string_literal: true

class TafBlock
  INDENTOR = '  '
  SEPARATOR = "\n"
  attr_reader :type, :properties, :children

  def initialize(type, *children, **properties, &)
    @type = type
    @children = children.select { _1.is_a?(TafBlock) }
    @properties = properties

    yield self if block_given?
  end

  def property(**new_properties)
    @properties.merge!(new_properties)
  end

  def child(*new_children)
    @children += new_children.select { _1.is_a?(TafBlock) }
  end

  def serialize(indent_level: 0, indent_with: '  ', separate_with: "\n")
    indent = [indent_with * indent_level].join
    separate_and_indent = [separate_with, indent, indent_with].join
    serialized_children = serialize_children(indent_level:, indent_with:, separate_with:)

    [ # tag_start
      indent, "{#{type}",
      # properties
      separate_and_indent, self.class.serialize_properies(properties, join_with: separate_and_indent),
      # children
      (children.present? && separate_with) || nil, serialized_children&.join(separate_with),
      # tag end
      separate_with, indent, '}'
    ].compact.join
  end

  def to_s
    serialize
  end

  def self.serialize_value(value) # rubocop:disable Metrics/MethodLength
    case value
    when ::FalseClass, ::TrueClass
      value ? '1' : '0'
    when ::BigDecimal, ::Float
      format('%.2f', value)
    when ::Numeric
      value.to_s
    when ::Date, ::DateTime
      value.strftime('%d.%m.%Y')
    else
      "\"#{value.to_s.gsub('"', '""')}\"".presence
    end
  end

  def serialize_children(indent_level:, indent_with:, separate_with:)
    children.map do |child|
      child.serialize(indent_level: indent_level + 1, indent_with:, separate_with:)
    end
  end

  def self.serialize_properies(properties, join_with: ' ')
    return '' unless properties.is_a?(Hash)

    properties.compact.flat_map { |key, value| "#{key}=#{serialize_value(value)}" }.join(join_with)
  end

  def self.derivers
    @derivers ||= {}
  end

  def self.register_deriver(klass, &derive_block)
    derivers[klass] = derive_block
  end

  def self.derive(value, **options)
    derive_block = derivers[derivers.keys.find { |klass| value.is_a?(klass) }]
    instance_exec(value, options, &derive_block) if derive_block.present?
  end

  register_deriver Accounting::JournalEntry do |value, **options|
    new(:Blg, *value.items.map { TafBlock.serialize(_1) }, **{
          # Date; The date of the booking.
          Date: options.fetch(:Date, value.date),

          Orig: true
        })
  end

  register_deriver Accounting::JournalEntryItem do |value, **options|
    new(:Bk, **{
          # The Id of a book keeping account. [Fibu-Konto]
          AccId: options.fetch(:AccId, value.account),

          # Integer; Booking type: 1=cost booking, 2=tax booking
          BType: options.fetch(:BType, value.amount_type == :tax || 1),

          # String[13], This is the cost type account
          CAcc: options.fetch(:CAcc, value.cost_center),

          # Integer; This is the index of the booking that represents the cost booking which is attached to this booking
          CIdx: options.fetch(:CIdx, value.index),

          # String[9]; A user definable code.
          Code: options.fetch(:Code, nil)&.slice(0..8),

          # Date; The date of the booking.
          Date: options.fetch(:Date, value.date),

          # IntegerAuxilliary flags. This value consists of the sum of one or more of
          # the following biases:
          # 1 - The booking is the first one into the specified OP.
          # 16 - This is a hidden booking. [Transitorische]
          # 32 - This booking is the exit booking, as oposed to the return booking.
          # Only valid if the hidden flag is set.
          Flags: options.fetch(:Flags, nil),

          # String[5]; The Id of the tax. [MWSt-Kürzel]
          TaxId: options.fetch(:TaxId, value.tax_code),

          # String[61*]; This string specifies the first line of the booking text.
          Text: options.fetch(:Text, value.text&.slice(0..59)&.lines&.first&.strip || '-'),

          #  String[*]; This string specifies the second line of the booking text.
          # (*)Both fields Text and Text2 are stored in the same memory location,
          # which means their total length may not exceed 60 characters (1 char is
          # required internally).
          # Be careful not to put too many characters onto one single line, because
          # most Reports are not designed to display a full string containing 60
          # characters.
          Text2: options.fetch(:Text2, value.text&.slice(0..59)&.lines&.[](1..-1)&.join("\n")),

          # Integer; This is the index of the booking that represents the tax booking
          # which is attached to this booking.
          TIdx: options.fetch(:TIdx, (value.amount_type == :tax && value.index) || nil),

          # Boolean; Booking type.
          # 0 a debit booking [Soll]
          # 1 a credit booking [Haben]
          Type: options.fetch(:Type, { 1 => 0, -1 => 1 }[value.side]),

          # Currency; The net amount for this booking. [Netto-Betrag]
          ValNt: options.fetch(:ValNt, value.amount_type == :netto ? value.amount : nil),

          # Currency; The tax amount for this booking. [Brutto-Betrag]
          ValBt: options.fetch(:ValBt, value.amount_type == :brutto ? value.amount : nil),

          # Currency; The tax amount for this booking. [Steuer-Betrag]
          ValTx: options.fetch(:ValTx, value.amount_type == :tax ? value.amount : nil),

          # Currency; The gross amount for this booking in the foreign currency specified
          # by currency of the account AccId. [FW-Betrag]
          # ValFW : not implemented

          # String[13]The OP id of this booking.
          OpId: options.fetch(:OpId, nil),

          # The PK number of this booking.
          PkKey: options.fetch(:PkKey, nil)
        })
  end
end
