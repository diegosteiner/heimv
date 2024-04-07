# frozen_string_literal: true

module Public
  module TenantParams
    class Update < ApplicationParamsSchema
      define do
        optional(:first_name).maybe(:string)
        optional(:last_name).maybe(:string)
        optional(:street_address).maybe(:string)
        optional(:zipcode).maybe(:string)
        optional(:city).maybe(:string)
        optional(:birth_date).maybe(:date)
        optional(:country_code).maybe(:string)
        optional(:nickname).maybe(:string)
        optional(:phone).maybe(:string)
        optional(:address_addon).maybe(:string)
        optional(:locale).maybe(:string)

        before(:key_coercer) do |result|
          params = result.to_h
          multiparam = params.slice('birth_date(1i)', 'birth_date(2i)', 'birth_date(3i)')
          next params unless multiparam.present? && params['birth_date'].blank?

          params[:birth_date] = multiparam.values.join('-')
          params
        end
      end
    end

    class Create < Update
      define do
        required(:email).filled(:string)
      end
    end
  end
end
