# frozen_string_literal: true

class Invoice
  class Item
    include StoreModel::Model
    include ActiveModel::Validations::Callbacks
    include Subtypeable
    extend ActiveModel::Translation
    extend TemplateRenderable
    include TemplateRenderable

    attr_accessor :suggested, :apply

    attribute :id
    attribute :accounting_account_nr
    attribute :accounting_cost_center_nr
    attribute :amount, :decimal
    attribute :breakdown
    attribute :label
    attribute :type
    attribute :usage_id
    attribute :deposit_id
    attribute :vat_category_id

    delegate :booking, :organisation, to: :invoice, allow_nil: true

    validates :type, presence: true, inclusion: { in: ->(_) { Invoice::Item.subtypes.keys.map(&:to_s) } }
    validates :id, presence: true

    before_validation do
      self.id = id.presence || Digest::UUID.uuid_v4
      self.type = type
      self.amount = amount&.floor(2) || 0
    end

    def type
      self.class.model_name.to_s
    end

    def invoice
      parent
    end

    def invoice=(value)
      self.parent = value
    end

    def usage
      @usage ||= invoice&.booking&.usages&.find_by(id: usage_id) if usage_id.present?
    end

    def tarif
      @tarif ||= usage&.tarif
    end

    def usage=(value)
      self.usage_id = value.is_a?(Usage) ? value.id : value
    end

    def vat_category=(value)
      self.vat_category_id = value.is_a?(VatCategory) ? value.id : value
    end

    def vat_category
      @vat_category ||= invoice&.organisation&.vat_categories&.find_by(id: vat_category_id) if vat_category_id.present?
    end

    def calculated_amount
      amount
    end

    def vat_breakdown
      @vat_breakdown ||= vat_category&.breakdown(amount) || { brutto: amount, netto: amount, vat: 0 }
    end

    def accounting_cost_center_nr
      @accounting_cost_center_nr ||= if super.to_s == 'home'
                                       invoice.booking.home&.settings&.accounting_cost_center_nr.presence
                                     else
                                       super.presence
                                     end
    end

    def to_sum(sum)
      sum + (calculated_amount || 0)
    end

    def self.one_of
      StoreModel.one_of do |json|
        subtypes[(json[:type].presence || json['type'].presence)&.to_sym] || Item
      end
    end
  end
end
