# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CrunchDataDigestJob, type: :job do
  let(:data_digest) { data_digest_template.data_digests.create }
  let(:data_digest_template) { create(:booking_data_digest_template) }
  before do
    create_list(:booking, 3, organisation: data_digest_template.organisation)
  end
  subject(:job) { described_class.perform_now(data_digest.id) }

  it { is_expected.to be_truthy }
end
