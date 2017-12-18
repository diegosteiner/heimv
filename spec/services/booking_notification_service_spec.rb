require 'rails_helper'

describe BookingNotificationService do
  let(:booking) { build_stubbed(:booking) }
  let(:service) { described_class.new(booking) }
  # let(:booking_mailer_view_model) { BookingMailerViewModel.new(booking) }

  describe '#confirm_request_notification' do
    let(:mail) { double }
    it do
      expect(BookingMailer).to receive(:confirm_request).with(instance_of(BookingMailerViewModel))
                                                        .and_return(mail)
      expect(mail).to receive(:deliver_now)
      service.confirm_request_notification
    end
  end
end
