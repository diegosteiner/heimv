# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationJob do
  let(:scope) { instance_double(Sentry::Scope, set_context: nil) }

  before do
    stub_const('DiscardingApplicationJob', Class.new(described_class) do
      discard_on StandardError

      def perform
        raise StandardError, 'application job failure'
      end
    end)

    allow(Sentry).to receive(:with_scope).and_yield(scope)
    allow(Sentry).to receive(:capture_exception)
    allow(ExceptionNotifier).to receive(:notify_exception)
    allow(Rails.error).to receive(:report)
  end

  it 'reports discarded exceptions to sentry and existing notifiers' do
    expect do
      DiscardingApplicationJob.perform_now
    end.to raise_error(StandardError, 'application job failure')

    expect(Rails.error).to have_received(:report).with(instance_of(StandardError))
    expect(ExceptionNotifier).to have_received(:notify_exception)
      .with(instance_of(StandardError), hash_including(:data))
    expect(Sentry).to have_received(:capture_exception).with(instance_of(StandardError))
  end
end
