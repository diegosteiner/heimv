# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Booking Index Performance' do
  let(:organisation) { create(:organisation) }
  let(:home) { create(:home, organisation:) }
  let(:organisation_user) { create(:organisation_user, organisation:, role: :manager) }

  before do
    sign_in organisation_user.user
    create_list(:booking, 50, home:, organisation:, initial_state: :definitive_request) # rubocop:disable FactoryBot/ExcessiveCreateList
  end

  describe 'GET /manage/bookings' do
    it 'responds in under 1200ms (warm cache)' do
      Rails.cache.clear

      response_time = measure_request_time { get manage_bookings_path }
      expect(response).to have_http_status(:ok)
      expect(response_time).to be < 2500

      response_time = measure_request_time { get manage_bookings_path }

      expect(response).to have_http_status(:ok)
      expect(response_time).to be < 1000
    end
  end

  private

  def measure_request_time
    start_time = Time.current
    yield
    end_time = Time.current

    ((end_time - start_time) * 1000)
  end
end
