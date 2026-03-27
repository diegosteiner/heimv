# frozen_string_literal: true

EmailAddress::Config.configure(local_format: :standard, host_validation: :syntax)
EmailAddress::Config.provider(:heimv_local, host_match: %w[heimv.local heimverwaltung.local heimv.test],
                                            host_validation: :syntax)
