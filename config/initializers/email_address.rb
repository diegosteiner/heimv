# frozen_string_literal: true

if Rails.env.production?
  EmailAddress::Config.configure(local_format: :standard, host_validation: :mx)
else
  EmailAddress::Config.configure(local_format: :standard, host_validation: :syntax)
end
EmailAddress::Config.provider(:heimv_local, host_match: %w[heimv.local heimverwaltung.local heimv.test],
                                            host_validation: :syntax)
