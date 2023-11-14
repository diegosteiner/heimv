# frozen_string_literal: true

require 'rspec/expectations'

RSpec::Matchers.define :use_mail_template do |mail_template|
  supports_block_expectations

  match do |use_block|
    expect(MailTemplate.by_key(mail_template)).to be_a(MailTemplate)
    expect(MailTemplate).to receive(:use).with(mail_template, anything,
                                               anything).and_wrap_original do |original, *args, &block|
      @notification = original.call(args[0], args[1], **(args[2] || {}), &block)
    end
    use_block.call
    expect(@notification).to(be_valid)
    expect(@notification.mail_template.key.to_sym).to(eq(mail_template.to_sym))
    expect(@notification).to(be_persisted) if @save || @deliver
    expect(@notification.instance_variable_get('@message_delivery')).to(be_present) if @deliver
    expect(@notification.to).to(eq(Array.wrap(@to))) if @to
    true
  end

  chain :and_deliver do
    @deliver = true
  end

  chain :and_save do
    @save = true
  end

  chain :to do |to|
    @to = to
  end
end
