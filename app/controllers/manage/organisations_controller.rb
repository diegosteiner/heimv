module Manage
  class OrganisationsController < BaseController
    load_and_authorize_resource :organisation
    before_action :set_organisation

    def edit; end

    def update
      @organisation.update(organisation_params)
      attach_files(
        terms_pdf: organisation_params[:terms_pdf],
        privacy_statement_pdf: organisation_params[:privacy_statement_pdf],
        logo: organisation_params[:logo]
      )
      respond_with :manage, current_organisation, location: edit_manage_organisation_path
    end

    private

    def set_organisation
      @organisation = Organisation.instance
    end

    def attach_files(attachments = {})
      attachments.each do |attachment_model, attachment|
        @organisation.send(attachment_model).attach(attachment) if attachment.present?
      end
    end

    def organisation_params
      params.require(:organisation).permit(:name, :address, :booking_strategy_type, :invoice_ref_strategy_type,
                                           :payment_information, :account_nr, :message_footer, :terms_pdf,
                                           :privacy_statement_pdf, :logo)
    end
  end
end
