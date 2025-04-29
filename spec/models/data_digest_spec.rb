# frozen_string_literal: true

# == Schema Information
#
# Table name: data_digests
#
#  id                      :bigint           not null, primary key
#  crunching_finished_at   :datetime
#  crunching_started_at    :datetime
#  data                    :jsonb
#  period_from             :datetime
#  period_to               :datetime
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  data_digest_template_id :bigint           not null
#  organisation_id         :bigint           not null
#

require 'rails_helper'

RSpec.describe DataDigest do
  subject(:data_digest) { create(:data_digest) }

  describe '#period' do
    it { expect(DataDigest::PERIODS[:ever].call(nil)).to eq(Range.new(nil, nil)) }
  end
end
