# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CleanDataDigestsJob, type: :job do
  subject(:job) { described_class.perform_now }

  before do
    create(:booking_data_digest_template).data_digests.create(created_at: 1.year.ago)
  end

  it { expect { job }.to change { DataDigest.all.count }.from(1).to(0) }
end
