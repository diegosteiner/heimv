# frozen_string_literal: true

class TafBlock
  INDENTOR = '  '
  SEPARATOR = "\n"
  attr_reader :type, :properties, :children

  def initialize(type, **properties, &)
    @type = type
    @properties = properties.transform_values { Value.cast(_1) }
    @children = Collection.new(&)
  end

  def self.block(...)
    new(...)
  end

  Value = Data.define(:value, :as) do
    CAST_BLOCKS = { # rubocop:disable Lint/ConstantDefinitionInBlock
      boolean: ->(value) { value ? '1' : '0' },
      decimal: ->(value) { format('%.2f', value) },
      number: ->(value) { value.to_i.to_s },
      date: ->(value) { value.strftime('%d.%m.%Y') },
      string: ->(value) { "\"#{value.gsub(/["']/, '""')}\"" },
      symbol: ->(value) { value.to_s },
      vector: ->(value) { "[#{value.to_a.map(&:to_s).join(',')}]" },
      value: ->(value) { value }
    }.freeze

    CAST_CLASSES = { # rubocop:disable Lint/ConstantDefinitionInBlock
      boolean: [::FalseClass, ::TrueClass],
      decimal: [::BigDecimal, ::Float],
      number: [::Numeric],
      date: [::Date, ::DateTime, ::ActiveSupport::TimeWithZone],
      string: [::String]
    }.freeze

    def self.cast(value, as: nil)
      return value if value.is_a?(Value)
      return nil if value.blank?

      as = CAST_CLASSES.find { |_key, klasses| klasses.any? { |klass| value.is_a?(klass) } }&.first if as.nil?
      value = CAST_BLOCKS.fetch(as).call(value)

      new(value, as)
    end

    def serialize
      value.to_s
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
    serialized_properties = properties.compact.map { |key, value| "#{key}=#{value.serialize}" }

    [ # tag_start
      indent, "{#{type}",
      # properties
      separate_and_indent, serialized_properties.join(separate_and_indent), separate_with,
      # children
      (separate_with if children.present?), serialized_children,
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

  def self.derive(value, **override)
    derive_block = factories[factories.keys.find { |klass| value.is_a?(klass) }]
    instance_exec(value, **override, &derive_block) if derive_block.present?
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

  derive_from Invoice do |invoice, **_override|
    next unless invoice.is_a?(Invoices::Invoice) || invoice.is_a?(Invoices::Deposit)

    op_id = Value.cast(invoice.human_ref, as: :symbol)
    pk_key = [invoice.booking.tenant.accounting_debitor_account_nr,
              invoice.organisation.accounting_settings.currency_account_nr].then { "[#{_1.join(',')}]" }

    journal_entries = invoice.journal_entries.flatten.compact

    [
      new(:OPd, **{ PkKey: pk_key, OpId: op_id, ZabId: '15T' }),
      new(:Blg, **{ OpId: op_id, Date: invoice.issued_at, Orig: true }) do
        derive(journal_entries.shift, Flags: 1, OpId: op_id)
        journal_entries.each { derive(_1, OpId: op_id) }
      end
    ]
  end

  derive_from Tenant do |tenant, **_override|
    [
      new(:Adr, **{
            AdrId: tenant.accounting_debitor_account_nr,
            Line1: tenant.full_name,
            Road: tenant.street_address,
            CCode: tenant.country_code,
            ACode: tenant.zipcode,
            City: tenant.city
          }),
      new(:PKd, **{
            PkKey: Value.cast(tenant.accounting_debitor_account_nr, as: :symbol),
            AdrId: Value.cast(tenant.accounting_debitor_account_nr, as: :symbol),
            AccId: Value.cast(tenant.organisation.accounting_settings.currency_account_nr, as: :symbol)
          })

    ]
  end
end
