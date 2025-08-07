# frozen_string_literal: true

class Invoice
  class Item
    include StoreModel::Model
    include ActiveModel::Validations::Callbacks
    include Subtypeable
    extend TemplateRenderable
    include TemplateRenderable

    attribute :id
    attribute :apply, :boolean, default: true
    attribute :accounting_account_nr
    attribute :accounting_cost_center_nr
    attribute :amount, :decimal
    attribute :breakdown
    attribute :label
    attribute :type
    attribute :usage_id
    attribute :vat_category_id

    delegate :booking, :organisation, to: :invoice, allow_nil: true

    validates :type, :presence, inclusion: { in: ->(_) { Invoice::Item.subtypes.keys.map(&:to_s) } }
    validates :id, :vat_category_id, presence: true, on: :create, if: :vat_category_required?
    validates :accounting_account_nr, presence: true, on: :create, if: :accounting_account_nr_required?

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

    def usage
      @usage ||= invoice&.booking&.usages&.find(usage_id) if usage_id.present?
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
      @vat_category ||= invoice&.organisation&.vat_categories&.find(vat_category_id) if vat_category_id.present?
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

    def sum_of_predecessors
      invoice.items.ordered.reduce(0) do |sum, item|
        break sum if item == self

        item.to_sum(sum)
      end
    end

    def to_sum(sum)
      sum + (calculated_amount || 0)
    end

    def accounting_account_nr_required?
      !to_sum(0).zero? && organisation&.accounting_settings&.enabled
    end

    def vat_category_required?
      !to_sum(0).zero? && organisation&.accounting_settings&.liable_for_vat
    end

    def self.one_of
      StoreModel.one_of do |json|
        subtypes[(json[:type].presence || json['type'].presence)&.to_sym] || Item
      end
    end

    # class Filter < ApplicationFilter
    #   attribute :homes, default: -> { [] }
    #   attribute :issued_at_after, :datetime
    #   attribute :issued_at_before, :datetime

    #   filter :homes do |items|
    #     relevant_homes = Array.wrap(homes).compact_blank
    #     if relevant_homes.present?
    #       items.joins(invoice: :booking).where(invoices: { bookings: { home_id: relevant_homes } })
    #     end
    #   end

    #   filter :issued_at do |items|
    #     next unless issued_at_before.present? || issued_at_after.present?

    #     items.joins(:invoice).where(Invoice.arel_table[:issued_at].between(issued_at_after..issued_at_before))
    #   end
    # end
  end
end
