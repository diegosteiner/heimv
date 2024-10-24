# frozen_string_literal: true

module Manage
  class TenantSerializer < ApplicationSerializer
    fields :salutation, :salutation_form, :first_name, :last_name, :street_address, :nickname, :name,
           :address_addon, :zipcode, :city, :email, :full_name, :contact_info, :phone, :names, :salutations,
           :address_lines, :full_address_lines, :birth_date, :country_code, :locale

    field :salutation_name do |tenant|
      tenant.salutations[:informal_neutral]
    end
  end
end
