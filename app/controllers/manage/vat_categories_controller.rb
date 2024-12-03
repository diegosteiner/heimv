# frozen_string_literal: true

module Manage
  class VatCategoriesController < BaseController
    load_and_authorize_resource :vat_category

    def index
      @vat_categories = @vat_categories.where(organisation: current_organisation).ordered
      respond_with :manage, @vat_categories
    end

    def edit
      respond_with :manage, @vat_category
    end

    def create
      @vat_category.organisation = current_organisation
      @vat_category.save
      respond_with :manage, location: manage_vat_categories_path
    end

    def update
      @vat_category.update(vat_category_params)
      respond_with :manage, location: manage_vat_categories_path
    end

    def destroy
      @vat_category.discarded? ? @vat_category.destroy : @vat_category.discard!
      respond_with :manage, @vat_category, location: manage_vat_categories_path
    end

    private

    def vat_category_params
      locale_params = I18n.available_locales.map { |locale| ["label_#{locale}"] }
      params.require(:vat_category).permit(:percentage, :accounting_vat_code, locale_params.flatten)
    end
  end
end
