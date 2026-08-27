# frozen_string_literal: true

class Tenant
  class Filter < ApplicationFilter
    attribute :q

    filter :q do |tenants|
      next tenants if q.blank?

      match_part = "%#{q.strip}%"
      tenants.where(Tenant.arel_table[:search_cache].matches(match_part))
    end
  end
end
