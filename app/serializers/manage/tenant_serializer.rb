# frozen_string_literal: true

module Manage
  class TenantSerializer < ApplicationSerializer
    fields :salutation_name, :first_name, :last_name, :street_address, :nickname,
           :address_addon, :zipcode, :city, :email, :name, :contact_info, :phone
  end
end
