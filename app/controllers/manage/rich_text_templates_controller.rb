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
      @missing_templates = RichTextTemplateService.new(current_organisation).missing_templates
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

    def create_missing
      created = RichTextTemplateService.new(current_organisation).create_missing!(enable_optional: false)
      redirect_to manage_rich_text_templates_path,
                  notice: t('manage.rich_text_templates.index.created_missing',
                            count: created.count,
                            list: created.map { it.title }.to_sentence)
    end

    def create
      @rich_text_template.organisation = current_organisation
      @rich_text_template.save
      respond_with :manage, @rich_text_template.becomes(RichTextTemplate)
    end

    def update
      load_locale_defaults = params.dig(:rich_text_template, :load_locale_defaults)
      @rich_text_template.assign_attributes(rich_text_template_params)
      @rich_text_template.load_locale_defaults(locales: load_locale_defaults) if load_locale_defaults.present?
      @rich_text_template.save
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
      template_keys = current_organisation.booking_flow_class.state_classes.values
      template_keys.to_h do |booking_state|
        templates = booking_state.rich_text_templates.keys.map do |key|
          @rich_text_templates.find_by(key:)
        end
        [booking_state, templates.compact_blank]
      end
    end

    def rich_text_templates_by_booking_action
      template_keys = current_organisation.booking_flow_class.manage_actions.values +
                      current_organisation.booking_flow_class.tenant_actions.values
      template_keys.to_h do |booking_action_class|
        templates = booking_action_class.rich_text_templates.keys.map do |key|
          @rich_text_templates.find_by(key:)
        end
        [booking_action_class, templates.compact_blank]
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
