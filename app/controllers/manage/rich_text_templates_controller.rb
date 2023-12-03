# frozen_string_literal: true

module Manage
  class RichTextTemplatesController < BaseController
    load_and_authorize_resource :rich_text_template
    respond_to :json
    helper_method :rich_text_templates_by_booking_action, :rich_text_templates_by_booking_state,
                  :rich_text_templates_by_rest, :rich_text_templates_by_document

    def index
      @rich_text_templates = @rich_text_templates.ordered.where(organisation: current_organisation)
      @rich_text_templates = @rich_text_templates.where(key: params[:key]) if params[:key]
    end

    def show
      respond_with :manage, @rich_text_template
    end

    def new
      dup = current_organisation.rich_text_templates.accessible_by(current_ability).find(params[:dup]) if params[:dup]
      @rich_text_template = dup&.dup || RichTextTemplate.new
      respond_with :manage, @rich_text_template
    end

    def edit
      respond_with :manage, @rich_text_template
    end

    def create
      @rich_text_template.organisation = current_organisation
      @rich_text_template.save
      respond_with :manage, @rich_text_template.becomes(RichTextTemplate)
    end

    def update
      @rich_text_template.update(rich_text_template_params)
      respond_with :manage, @rich_text_template.becomes(RichTextTemplate)
    end

    def destroy
      @rich_text_template.destroy
      respond_with :manage, @rich_text_template, location: manage_rich_text_templates_path
    end

    private

    def rich_text_template_params
      RichTextTemplateParams.new(params.require(:rich_text_template)).permitted
    end

    def rich_text_templates_by_booking_state
      current_organisation.booking_flow_class.state_classes.values.to_h do |booking_state|
        templates = booking_state.templates.map { |definition| @rich_text_templates.find_by(key: definition[:key]) }
        [booking_state, templates.compact_blank]
      end
    end

    def rich_text_templates_by_booking_action
      (BookingActions::Manage.all.values + BookingActions::Public.all.values).to_h do |booking_action|
        templates = booking_action.templates.map { |definition| @rich_text_templates.find_by(key: definition[:key]) }
        [booking_action, templates.compact_blank]
      end
    end

    def rich_text_templates_by_document
      {
        Invoices::Offer => @rich_text_templates.where(key: :invoices_offer_text),
        Invoices::Deposit => @rich_text_templates.where(key: :invoices_deposit_text),
        Invoices::Invoice => @rich_text_templates.where(key: :invoices_invoice_text),
        Invoices::LateNotice => @rich_text_templates.where(key: :invoices_late_notice_text),
        Contract => @rich_text_templates.where(key: :contract_text),
        PaymentInfos::TextPaymentInfo => @rich_text_templates.where(key: :text_payment_info_text),
        PaymentInfos::ForeignPaymentInfo => @rich_text_templates.where(key: :foreign_payment_info_text)
      }.filter { _2.present? }
    end

    def rich_text_templates_by_rest
      @rich_text_templates.to_a -
        rich_text_templates_by_booking_action.values.flatten -
        rich_text_templates_by_document.values.flatten -
        rich_text_templates_by_booking_state.values.flatten
    end
  end
end
