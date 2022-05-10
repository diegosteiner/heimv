# frozen_string_literal: true

module Manage
  class TenantSerializer < ApplicationSerializer
    fields :salutation_name, :first_name, :last_name, :street_address, :nickname, :name,
           :address_addon, :zipcode, :city, :email, :full_name, :contact_info, :phone
  end
end
