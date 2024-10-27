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

  def serialize(indent_level: 0, indent_with: '  ', separate_with: "\n") # rubocop:disable Metrics/MethodLength
    indent = [indent_with * indent_level].join
    separate_and_indent = [separate_with, indent, indent_with].join
    serialized_children = children.map do |child|
      child.serialize(indent_level: indent_level + 1, indent_with:, separate_with:)
    end

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
    when ::Date
      value.strftime('%d.%m.%Y')
    else
      "\"#{value.to_s.gsub('"', '""')}\""
    end
  end

  def self.serialize_properies(properties, join_with: ' ')
    return '' unless properties.is_a?(Hash)

    properties.compact.flat_map { |key, value| "#{key}=#{serialize_value(value)}" }.join(join_with)
  end

  def self.converters
    @converters ||= {}
  end

  def self.register_converter(klass, &conversion_block)
    converters[klass] = conversion_block
  end

  def self.convert(value, **options)
    conversion_block = converters[converters.keys.find { |klass| value.is_a?(klass) }]
    instance_exec(value, options, &conversion_block) if conversion_block.present?
  end

  register_converter Accounting::JournalEntry do |value, _options|
    new(:Bk, **{
          # The Id of a book keeping account. [Fibu-Konto]
          AccId: value.account_id,
          # Integer; Booking type: 1=cost booking, 2=tax booking
          BType: value.b_type.presence || 1,
          # String[13], This is the cost type account
          CAcc: value.cost_account_id,
          # Integer; This is the index of the booking that represents the cost booking which is attached to this booking
          CIdx: value.cost_index,
          # String[9]; A user definable code.
          Code: value.code&.slice(0..8),
          # Date; The date of the booking.
          Date: value.date,
          # IntegerAuxilliary flags. This value consists of the sum of one or more of
          # the following biases:
          # 1 - The booking is the first one into the specified OP.
          # 16 - This is a hidden booking. [Transitorische]
          # 32 - This booking is the exit booking, as oposed to the return booking.
          # Only valid if the hidden flag is set.
          Flags: value.flags,
          # String[5]; The Id of the tax. [MWSt-Kürzel]
          TaxId: value.tax_id,
          # String[61*]; This string specifies the first line of the booking text.
          Text: value.text&.slice(0..59)&.lines&.first&.strip || '-',
          #  String[*]; This string specifies the second line of the booking text.
          # (*)Both fields Text and Text2 are stored in the same memory location,
          # which means their total length may not exceed 60 characters (1 char is
          # required internally).
          # Be careful not to put too many characters onto one single line, because
          # most Reports are not designed to display a full string containing 60
          # characters.
          Text2: value.text&.slice(0..59)&.lines&.[](1..-1)&.join("\n"),
          # Integer; This is the index of the booking that represents the tax booking
          # which is attached to this booking.
          TIdx: value.tax_index,
          # BooleanBooking type.
          # 0 a debit booking [Soll]
          # 1 a credit booking [Haben]
          Type: value.type.to_i,
          # Currency; The net amount for this booking. [Netto-Betrag]
          ValNt: value.amount_netto,
          # Currency; The tax amount for this booking. [Brutto-Betrag]
          ValBt: value.amount_brutto,
          # Currency; The tax amount for this booking. [Steuer-Betrag]
          ValTx: value.amount_tax,
          # Currency; The gross amount for this booking in the foreign currency specified
          # by currency of the account AccId. [FW-Betrag]
          # ValFW :
          # String[13]The OP id of this booking.
          OpId: value.op_id,
          # The PK number of this booking.
          PkKey: value.pk_id
        })
  end
end
