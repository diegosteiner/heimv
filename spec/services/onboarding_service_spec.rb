# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OnboardingService, type: :model do
  describe '.create' do
    it 'sets nickname label translations for all available locales' do
      service = described_class.create(name: 'Test Organisation', email: 'test@example.org')
      organisation = service.organisation.reload
      nickname_label = I18n.available_locales.to_h { [it.to_s, Tenant.human_attribute_name(:nickname, locale: it)] }

      expect(organisation.nickname_label_i18n).to include(nickname_label)
    end
  end
end
