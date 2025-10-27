# frozen_string_literal: true

module Manage
  class TenantSerializer < ApplicationSerializer
    identifier :id
    fields :salutation, :salutation_form, :first_name, :last_name, :street, :street_nr, :nickname, :name,
           :address_addon, :zipcode, :city, :email, :full_name, :contact_info, :phone, :names, :salutations,
           :birth_date, :country_code, :locale, :ref, :address_lines

    # legacy fields
    field :street_address do |tenant|
      tenant.address&.street_line
    end

    field :salutation_name do |tenant|
      tenant.salutations[:informal_neutral]
    end
  end
end
