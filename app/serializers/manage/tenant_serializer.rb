# frozen_string_literal: true

module Manage
  class TenantSerializer < ApplicationSerializer
    fields :salutation_name, :salutation_form, :first_name, :last_name, :street_address, :nickname, :name,
           :address_addon, :zipcode, :city, :email, :full_name, :contact_info, :phone,
           :address_lines, :full_address_lines, :birth_date, :country_code, :locale
  end
end
