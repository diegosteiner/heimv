require 'rails_helper'

RSpec.describe BookingMailer, type: :mailer do
  let(:booking) { create(:booking) }
  let(:mail_to) { 'email@hv.test' }
  let(:mail_from) { Rails.application.secrets.mail_from }
  let(:vm) { BookingMailerViewModel.new(booking, mail_to) }
  before { allow(Rails.application.secrets).to receive(:MAIL_FROM).and_return(mail_from) }

  describe 'mailer_methods' do
    # mailer_methods = %i[
    #   confirm_request new_request_confirmed provisional_request_confirmed request_declined
    #   definitive_request_confirmed placement_confirmed provisional_request_overdue
    #   overdue_request_cancelled booking_confirmed contract_recieved deposit_or_contract_due
    #   overdue_booking_cancelled bill payment_received payment_overdue
    # ]
    mailer_methods = %i[confirm_request]

    mailer_methods.each do |mailer_method|
      it mailer_method.to_s do
        mail = described_class.send(mailer_method, vm)
        expect(mail.subject).to eq(I18n.t("booking_mailer.#{mailer_method}.subject"))
        expect(mail.to).to eq([mail_to])
        expect(mail.from).to eq([mail_from])
        # expect(mail.body.encoded).to match(I18n.t("booking_mailer.#{mailer_method}.body"))
      end
    end
  end
end
